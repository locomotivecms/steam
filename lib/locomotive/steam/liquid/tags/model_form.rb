module Locomotive
  module Steam
    module Liquid
      module Tags

        # Display the form html tag with the appropriate hidden fields in order to create
        # a content entry from a public site.
        # It handles callbacks, csrf and target url out of the box.
        #
        # Usage:
        #
        # {% model_form 'newsletter_addresses' %}
        #    <input type='text' name='content[email]' />
        #     <input type='submit' value='Add' />
        # {% endform_form %}
        #
        # {% model_form 'newsletter_addresses', class: 'a-css-class', success: 'http://www.google.fr', error: '/error' %}...{% endform_form %}
        #
        class ModelForm < Solid::Block

          tag_name :model_form

          def display(*options, &block)
            name    = options.shift
            options = options.shift || {}

            form_attributes = prepare_form_attributes(options)

            html_content_tag :form,
              content_type_html(name) + csrf_html + callbacks_html(options) + yield,
              form_attributes
          end

          def content_type_html(name)
            html_tag :input, type: 'hidden', name: 'content_type_slug', value: name
          end

          def csrf_html
            service = current_context.registers[:services].csrf_protection

            html_tag :input, type: 'hidden', name: service.field, value: service.token
          end

          def callbacks_html(options)
            options.slice(:success, :error).map do |(name, value)|
              html_tag :input, type: 'hidden', name: "#{name}_callback", value: value
            end.join('')
          end

          private

          def html_content_tag(name, content, options = {})
            "<#{name} #{inline_options(options)}>#{content}</#{name}>"
          end

          def html_tag(name, options = {})
            "<#{name} #{inline_options(options)} />"
          end

          # Write options (Hash) into a string according to the following pattern:
          # <key1>="<value1>", <key2>="<value2", ...etc
          def inline_options(options = {})
            return '' if options.empty?
            (options.stringify_keys.to_a.collect { |a, b| "#{a}=\"#{b}\"" }).join(' ')
          end

          def prepare_form_attributes(options)
            url         = action_url(options)
            attributes  = options.slice(:id, :class, :name, :novalidate)

            { method: 'POST', enctype: 'multipart/form-data' }.merge(attributes).tap do |_attributes|
              _attributes[:action] = url if url
            end
          end

          def action_url(options)
            url = options[:action]

            if url.blank?
              if options[:json]
                url = current_context['path'].blank? ? '/' : current_context['path']
                url + 'index.json'
              else
                nil
              end
            else
              url = '/' + url unless url.starts_with?('/')
              url_builder.prefix(url)
            end
          end

          def url_builder
            current_context.registers[:services].url_builder
          end

        end

      end
    end
  end
end
