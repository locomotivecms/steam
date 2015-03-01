module Locomotive
  module Steam

    class ContentEntryRepository

      include Models::Repository

      attr_reader   :content_type_repository
      attr_accessor :content_type, :local_conditions

      def initialize(adapter, site = nil, locale = nil, content_type_repository = nil)
        @local_conditions = {}
        @adapter  = adapter
        @scope    = Locomotive::Steam::Models::Scope.new(site, locale)
        @content_type_repository = content_type_repository
      end

      # Entity mapping
      mapping :content_entries, entity: ContentEntry do
        localized_attributes :_slug, :seo_title, :meta_description, :meta_keywords

        default_attribute :content_type, -> (repository) { repository.content_type }
      end

      # this is the starting point of all the next actions
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
          unless self.content_type.localized_fields_names.blank?
            mapper.localized_attributes(*self.content_type.localized_fields_names)
          end

          self.content_type.belongs_to_fields.each do |field|
            mapper.belongs_to_association(field.name, self.class, {}) do |repository|
              # TODO: load the content type (adapter.id_names[:content_types])
              repository.content_type
            end # field.association_options)
          end
        end
      end

      def prepare_conditions(*conditions)
        [*conditions].inject({}) do |memo, hash|
          memo.merge!(hash) unless hash.blank?
          memo
        end.merge(@local_conditions)
      end

      # def type_from(slug)
      #   content_type_repository.by_slug(slug)
      # end

      # def localized_slug(entry)
      #   raise 'SHOULD NOT BE USED'
      #   localized_attribute(entry, :_slug)
      # end

      # def association(metadata, conditions = {})
      #   case metadata.type
      #   when :belongs_to    then belongs_to_association(metadata)
      #   when :has_many      then has_many_association(metadata, conditions)
      #   when :many_to_many  then many_to_many_association(metadata, conditions)
      #   end
      # end

      # def belongs_to_association(metadata)
      #   type = type_from(metadata.target_class_slug)
      #   by_slug(type, metadata.target_slugs.first)
      # end

      # def has_many_association(metadata, conditions)
      #   many_association(metadata,
      #     { metadata.target_field => localized_slug(metadata.source) }.merge(conditions))
      # end

      # def many_to_many_association(metadata, conditions)
      #   many_association(metadata,
      #     { '_slug.in' => metadata.target_slugs }.merge(conditions))
      # end

      # def many_association(metadata, conditions)
      #   type = type_from(metadata.target_class_slug)

      #   if order_by = metadata.order_by
      #     conditions = { order_by: order_by }.merge(conditions)
      #   end

      #   all(type, conditions)
      # end

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
