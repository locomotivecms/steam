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

      def all(conditions = {})
        conditions = prepare_conditions({ _visible: true }, conditions)

        # priority:
        # 1/ order_by passed in the conditions parameter
        # 2/ the default order (_position) defined in the content type
        order_by = conditions.delete(:order_by)|| conditions.delete('order_by') || content_type.order_by

        query { where(conditions).order_by(order_by) }.all
      end

      def find(id)
        name = adapter.identifier_name(mapper)
        conditions = prepare_conditions(name => id)
        first { where(conditions) }
      end

      def exists?(conditions = {})
        conditions = prepare_conditions(conditions)
        query { where(conditions) }.all.size > 0
      end

      def by_slug(slug)
        conditions = prepare_conditions(_slug: slug)
        first { where(conditions) }
      end

      def next(entry)
        next_or_previous(entry, 'gt', 'lt')
      end

      def previous(entry)
        next_or_previous(entry, 'lt', 'gt')
      end

      def group_by_select_option(name)
        return {} if name.nil? || content_type.nil? || content_type.fields_by_name[name].type != :select

        _groups = all.group_by { |entry| i18n_value_of(entry, name) }

        groups = content_type_repository.select_options(content_type, name).map do |option|
          { name: option, entries: _groups.delete(option) || [] }
        end

        unless _groups.blank?
          groups << (empty = { name: nil, entries: [] })
          _groups.values.each { |list| empty[:entries] += list }
        end

        groups
      end

      private

      def mapper(memoized = false)
        super(memoized).tap do |mapper|
          add_localized_fields_to_mapper(mapper)
          add_associations_to_mapper(mapper)
        end
      end

      def add_localized_fields_to_mapper(mapper)
        unless self.content_type.localized_fields_names.blank?
          mapper.localized_attributes(*self.content_type.localized_fields_names)
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

        name, direction = self.content_type.order_by.split
        op = direction == 'asc' ? asc_op : desc_op

        conditions = prepare_conditions({ k(name, op) => i18n_value_of(entry, name) })

        first { where(conditions) }
      end

    end

  end
end
