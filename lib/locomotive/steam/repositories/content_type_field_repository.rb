module Locomotive
  module Steam

    class ContentTypeFieldRepository

      include Models::Repository

      attr_accessor :content_type

      # Entity mapping
      mapping :content_type_fields, entity: ContentTypeField do
        default_attribute :content_type, -> (repository) { repository.content_type }

        embedded_association :select_options, ContentTypeFieldSelectOptionRepository
      end

      def by_name(name)
        first { where(name: name) }
      end

      def selects
        query { where(type: :select) }.all
      end

      def files
        query { where(type: :file) }.all
      end

      def passwords
        query { where(type: :password) }.all
      end

      def dates_and_date_times
        query { where(k(:type, :in) => %i(date date_time)) }.all
      end

      def belongs_to
        query { where(type: :belongs_to) }.all
      end

      def many_to_many
        query { where(type: :many_to_many) }.all
      end

      def associations
        query { where(k(:type, :in) => %i(belongs_to has_many many_to_many)) }.all
      end

      def no_associations
        query { where(k(:type, :nin) => %i(belongs_to has_many many_to_many)) }.all
      end

      def unique
        query { where(unique: true) }.all.inject({}) do |memo, field|
          memo[field.name] = field
          memo
        end
      end

      def required
        query { where(required: true) }.all
      end

      def localized_names
        query { where(localized: true) }.all.map do |field|
          field.type == :select ? [field.name, "#{field.name}_id"] : field.name
        end.flatten
      end

      def default
        query { where(k(:default, :neq) => nil, k(:type, :in) => [:string, :text, :color, :select, :boolean, :email, :integer, :float]) }.all
      end

      def select_options(name)
        if field = first { where(name: name, type: :select) }
          field.select_options.all
        else
          nil
        end
      end

    end
  end
end
