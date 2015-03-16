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
        entity_klass.new(deserialize(attributes)).tap do |entity|
          attach_entity_to_associations(entity)

          set_default_attributes(entity)

          entity.localized_attributes = @localized_attributes_hash || {}

          entity.base_url = @repository.base_url(entity)
        end
      end

      def deserialize(attributes)
        build_localized_attributes(attributes)
        build_associations(attributes)
        attributes
      end

      def entity_klass
        options[:entity]
      end

      def i18n_value_of(entity, name, locale)
        value = entity.send(name.to_sym)
        value.respond_to?(:translations) ? value[locale] : value
      end

      private

      # create a proxy class for each localized attribute
      def build_localized_attributes(attributes)
        @localized_attributes.each do |name|
          attributes[name] = I18nField.new(name, attributes[name])
        end
      end

      # create a proxy class for each association
      def build_associations(attributes)
        @associations.each do |(type, name, repository_klass, options, block)|
          klass = ASSOCIATION_CLASSES[type]

          _options = options.merge({
            association_name: name,
            mapper_name:      self.name
          })

          attributes[name] = (if type == :embedded
            klass.new(repository_klass, attributes[name], @repository.scope, _options)
          else
            klass.new(repository_klass, @repository.scope, @repository.adapter, _options, &block)
          end)
        end
      end

      def attach_entity_to_associations(entity)
        @associations.each do |(type, name, _)|
          entity[name].__attach__(entity)
        end
      end

      def set_default_attributes(entity)
        @default_attributes.each do |(name, value)|
          _value = value.respond_to?(:call) ? value.call(@repository) : value
          entity.send(:"#{name}=", _value)
        end
      end

    end

  end
end
