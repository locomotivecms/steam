module Locomotive::Steam
  module Models

    class Mapper

      ASSOCIATION_CLASSES = {
        embedded:     EmbeddedAssociation,
        belongs_to:   BelongsToAssociation,
        has_many:     HasManyAssociation,
        many_to_many: ManyToManyAssociation
      }.freeze

      attr_reader :name, :options, :default_attributes, :localized_attributes, :associations

      def initialize(name, options, repository, &block)
        @name, @options, @repository = name, options, repository

        @localized_attributes = []
        @default_attributes   = []
        @associations         = []

        @entity_map           = {}

        instance_eval(&block) if block_given?
      end

      def localized_attributes(*args)
        @localized_attributes += [*args]

        @localized_attributes_hash = @localized_attributes.inject({}) do |hash, attribute|
          hash[attribute.to_sym] = true; hash
        end

        @localized_attributes
      end

      def default_attribute(name, value)
        @default_attributes += [[name.to_sym, value]]
      end

      ASSOCIATION_CLASSES.each do |type, _|
        define_method("#{type}_association") do |name, repository_klass, options = nil, &block|
          association(type, name, repository_klass, options, &block)
        end
      end

      def association(type, name, repository_klass, options = nil, &block)
        @associations << [type, name.to_sym, repository_klass, options || {}, block]
      end

      def to_entity(attributes)
        cache_entity(entity_klass, attributes) do
          entity_klass.new(deserialize(attributes)).tap do |entity|
            set_default_attributes(entity)

            entity.localized_attributes = @localized_attributes_hash || {}
            entity.associations = {}

            attach_entity_to_associations(entity)

            entity.base_url = @repository.base_url(entity)
          end
        end
      end

      def deserialize(attributes)
        build_localized_attributes(attributes)
        build_associations(attributes)
        attributes
      end

      def serialize(entity)
        entity.serialize.tap do |attributes|
          # scope
          @repository.scope.apply(attributes)

          # localized fields
          @localized_attributes.each do |name|
            entity.send(name).serialize(attributes)
          end

          # association name -> id (belongs_to) or ids (many_to_many)
          (entity.associations || {}).each do |name, association|
            association.__serialize__(attributes)
          end
        end
      end

      def entity_klass
        options[:entity]
      end

      def i18n_value_of(entity, name, locale)
        value = entity.send(name.to_sym)
        value.respond_to?(:translations) ? value[locale] : value
      end

      def reset_entity_map
        @entity_map = {}
      end

      private

      # create a proxy class for each localized attribute
      def build_localized_attributes(attributes)
        @localized_attributes.each do |name|
          _name = name.to_sym
          attributes[_name] = I18nField.new(_name, attributes[name.to_s] || attributes[_name])
        end
      end

      # create a proxy class for each association
      def build_associations(attributes)
        @associations.each do |(type, name, repository_klass, options, block)|
          klass = ASSOCIATION_CLASSES[type]

          _options = options.merge(association_name: name, mapper_name: self.name)

          attributes[name] = (if type == :embedded
            klass.new(repository_klass, attributes[name], @repository.scope, _options)
          else
            klass.new(repository_klass, @repository.scope, @repository.adapter, _options, &block)
          end)
        end
      end

      def attach_entity_to_associations(entity)
        @associations.each do |(type, name, _)|
          association = entity[name]
          association.__attach__(entity)

          entity.associations[name] = association
        end
      end

      def set_default_attributes(entity)
        @default_attributes.each do |(name, value)|
          _value = value.respond_to?(:call) ? value.call(@repository) : value
          entity.send(:"#{name}=", _value)
        end
      end

      def cache_entity(entity_klass, attributes, &block)
        return yield if attributes['_id'].blank?

        key = "#{entity_klass.to_s}-#{attributes['_id']}"

        if (entity = @entity_map[key]).nil?
          entity = @entity_map[key] = yield
        end

        entity
      end

    end

  end
end
