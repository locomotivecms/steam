module Locomotive
  module Steam
    module Liquid
      module Drops
        class ContentEntry < I18nBase

          delegate :_slug, :_translated, :seo_title, :meta_keywords, :meta_description, :created_at, :updated_at, to: :@_source

          alias :_permalink :_slug

          def _id
            @_source._id.to_s
          end

          def _label
            @_label ||= @_source._label
          end

          # Returns the content_entry type's slug and entry slug
          # as a means of expressing a unique object to fascilitate
          # looking up a specific object. Intended to be used within
          # a capture block
          #
          # Usage:
          #
          # {% capture selected_object %}
          #   {{ contents.products.first.select }}
          # {% endcapture %}
          #
          def select
            "~" + @_source.content_type._id + "#" + _id
          end
          

          # Returns the next content for the parent content type.
          # If no content is found, nil is returned.
          #
          # Usage:
          #
          # {% if article.next %}
          # <a href="{% path_to article.next %}">Read next article</a>
          # {% endif %}
          #
          def next
            @next ||= repository(@_source).next(@_source).to_liquid
          end

          # Returns the previous content for the parent content type.
          # If no content is found, nil is returned.
          #
          # Usage:
          #
          # {% if article.previous %}
          # <a href="{% path_to article.previous %}">Read previous article</a>
          # {% endif %}
          #
          def previous
            @previous ||= repository(@_source).previous(@_source).to_liquid
          end

          def errors
            if @_source.errors.blank?
              false
            else
              @_source.errors.messages.to_hash.stringify_keys
            end
          end

          def before_method(meth)
            return '' if @_source.nil?

            if not @@forbidden_attributes.include?(meth.to_s)
              repository(@_source).value_for(@_source, meth, conditions_for(meth))
            else
              nil
            end
          end

          def to_hash
            @_source.to_hash.tap do |hash|
              hash['id'] = hash['_id']

              @_source.content_type.fields_by_name.each do |name, field|
                case field.type
                when :belongs_to
                  hash[name] = liquify_entry(@_source.send(name))._slug
                when :many_to_many
                  hash[name] = (@_source.send(name) || []).all.map { |e| liquify_entry(e)._slug }.compact
                when :file
                  hash[name] = hash["#{name}_url"] = file_field_to_url(hash[name.to_s]) if hash[name.to_s].present?
                when :select
                  hash[name] = @_source.send(name) if hash["#{name}_id"].present?
                end
              end
            end
          end

          def as_json(options = nil)
            self.to_hash.as_json(options)
          end

          protected

          def liquify_entry(entry)
            self.class.new(entry).tap { |drop| drop.context = @context }
          end

          def file_field_to_url(field)
            field.to_liquid.tap { |drop| drop.context = @context }.url
          end

          def repository(entry)
            repository = @context.registers[:services].repositories.content_entry
            repository.with(entry.content_type)
          end

          def conditions_for(name)
            # note: treat conditions only they apply to the content type (if it's a has_many/many_to_many relationships)
            _name = @context['with_scope_content_type']
            !_name || _name == name ? @context['with_scope'] : nil
          end

        end
      end
    end
  end
end
