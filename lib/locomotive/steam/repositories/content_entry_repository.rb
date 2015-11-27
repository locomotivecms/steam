module Locomotive
  module Steam

    class ContentEntryRepository

      include Models::Repository

      attr_accessor :content_type_repository, :content_type

      def initialize(adapter, site = nil, locale = nil, content_type_repository = nil)
        @adapter  = adapter
        @scope    = Locomotive::Steam::Models::Scope.new(site, locale)
        @content_type_repository = content_type_repository
        @local_conditions = {}
        @memoized_mappers = {}
      end

      # Entity mapping
      mapping :content_entries, entity: ContentEntry do
        localized_attributes :_slug, :seo_title, :meta_description, :meta_keywords

        default_attribute :content_type, -> (repository) { repository.content_type }
      end

      # this is the starting point of all the next methods
      def with(type)
        self.content_type = type # used for creating the scope
        self.scope.context[:content_type] = type

        @local_conditions[:content_type_id] = type.try(:_id)

        self # chainable
      end

      def all(conditions = {}, &block)
        conditions, order_by = conditions_without_order_by(conditions)

        # priority:
        # 1/ order_by passed in the conditions parameter
        # 2/ the default order (_position) defined in the content type
        order_by ||= content_type.order_by

        query {
          (block_given? ? instance_eval(&block) : where).
            where(conditions).
              order_by(order_by)
        }.all
      end

      def count(conditions = {})
        conditions, _ = conditions_without_order_by(conditions)
        super() { where(conditions) }
      end

      def find(id)
        conditions, _ = conditions_without_order_by(_id: id)
        first { where(conditions) }
      end

      def exists?(conditions = {})
        conditions, _ = conditions_without_order_by(conditions)
        query { where(conditions) }.all.size > 0
      end

      def by_slug(slug)
        conditions, _ = conditions_without_order_by(_slug: slug)
        first { where(conditions) }
      end

      def value_for(entry, name, conditions = {})
        return nil if entry.nil?

        if field = content_type.fields_by_name[name]
          value = entry.send(name)

          if %i(has_many many_to_many).include?(field.type)
            # a safe copy of the proxy repository is needed here
            value = value.dup
            # like this, we do not modify the original local conditions
            value.local_conditions.merge!(conditions) if conditions
          end

          value
        end
      end

      def next(entry)
        next_or_previous(entry, 'gt', 'lt')
      end

      def previous(entry)
        next_or_previous(entry, 'lt', 'gt')
      end

      def group_by_select_option(name)
        return {} if name.nil? || content_type.nil? || content_type.fields_by_name[name].type != :select

        # a big one request to get them grouped by the field
        _groups = all.group_by { |entry| i18n_value_of(entry, name) }

        groups_to_array(name, _groups).tap do |groups|
          # entries with a not existing select_option value?
          unless _groups.blank?
            groups << { name: nil, entries: _groups.values.flatten }
          end
        end
      end

      def to_liquid
        Locomotive::Steam::Liquid::Drops::ContentEntryCollection.new(content_type, self)
      end

      private

      def mapper
        key = self.content_type._id.to_s

        return @memoized_mappers[key] if @memoized_mappers[key]

        @memoized_mappers[key] = super(false).tap do |mapper|
          add_localized_fields_to_mapper(mapper)
          add_associations_to_mapper(mapper)
        end
      end

      def conditions_without_order_by(conditions = {})
        _conditions = prepare_conditions(conditions)
        order_by = _conditions.delete(:order_by) || _conditions.delete('order_by')
        [_conditions, order_by]
      end

      def prepare_conditions(*conditions)
        _conditions = Conditions.new(conditions.first, self.content_type.fields).prepare

        super({ _visible: true }, _conditions)
      end

      def add_localized_fields_to_mapper(mapper)
        unless self.content_type.localized_names.blank?
          mapper.localized_attributes(*self.content_type.localized_names)
        end
      end

      def add_associations_to_mapper(mapper)
        self.content_type.association_fields.each do |field|
          mapper.association(field.type, field.name, self.class, field.association_options, &method(:prepare_repository_for_association))
        end
      end

      # This code is executed once when the association proxy object receives a call to any method
      def prepare_repository_for_association(repository, options)
        # load the target content type
        _content_type = content_type_repository.find(options[:target_id])

        # the target repository uses this content type for all the other inner calls
        repository.with(_content_type)

        # the content type repository is also need by the target repository
        repository.content_type_repository = content_type_repository
      end

      def next_or_previous(entry, asc_op, desc_op)
        return nil if entry.nil?

        with(entry.content_type)

        order_by = self.content_type.order_by
        name, direction = order_by.first
        op = direction == 'asc' ? asc_op : desc_op

        conditions = prepare_conditions({ k(name, op) => i18n_value_of(entry, name) })

        public_send(op == 'gt' ? :last : :first) do
          where(conditions).order_by(order_by)
        end
      end

      def groups_to_array(name, groups)
        content_type_repository.select_options(content_type, name).map do |option|
          option_name = i18n_value_of(option, :name)
          { name: option_name, entries: groups.delete(option_name) || [] }
        end
      end

      class Conditions

        def initialize(conditions = {}, fields)
          @conditions, @fields, @operators = conditions.try(:with_indifferent_access) || {}, fields, {}

          @conditions.each do |name, value|
            _name, operator = name.to_s.split('.')
            @operators[_name] = operator if operator
          end
        end

        def prepare
          # selects
          _prepare(@fields.selects) do |field, value|
            field.select_options.by_name(value).try(:_id)
          end

          # belongs_to
          _prepare(@fields.belongs_to) { |field, value| value_to_id(value) }

          # many_to_many
          _prepare(@fields.many_to_many) { |field, value| values_to_ids(value) }

          @conditions
        end

        protected

        def _prepare(fields, &block)
          fields.each do |field|
            name      = field.name.to_s
            operator  = @operators[name]
            _name     = operator ? "#{name}.#{operator}" : name

            if value = @conditions[_name]
              # delete old name
              @conditions.delete(_name)

              # build the new name with the prefix and the operator if there is one
              _name = field.persisted_name + (operator ? ".#{operator}" : '')

              # store the new name
              @conditions[_name] = yield(field, value)
            end
          end
        end

        def value_to_id(value)
          value.respond_to?(:_id) ? value._id : value
        end

        def values_to_ids(value)
          [*value].map { |_value| value_to_id(_value) }
        end

      end

    end

  end
end
