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
        class ModelForm < ::Liquid::Block

          include Concerns::SimpleAttributesParser

          Syntax = /(#{::Liquid::QuotedFragment})\s*,*(.*)?/o.freeze

          attr_reader :name

          def initialize(tag_name, markup, options)
            super

            if markup =~ Syntax
              @name, _attributes = $1, $2

              parse_attributes(_attributes)
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'model_form' - Valid syntax: model_form <content_type_slug>(, <attributes>)")
            end
          end

          def render(context)
            @name = context[name]

            evaluate_attributes(context)

            form_attributes = prepare_form_attributes(context, attributes)

            html_content_tag(
              :form,
              content_type_html(name) + csrf_html(context) + callbacks_html(attributes) + recaptcha_html(attributes) + super,
              form_attributes
            )
          end

          def content_type_html(name)
            html_tag :input, type: 'hidden', name: 'content_type_slug', value: name
          end

          def csrf_html(context)
            service = context.registers[:services].csrf_protection

            html_tag :input, type: 'hidden', name: service.field, value: service.token
          end

          def callbacks_html(options)
            options.slice(:success, :error).map do |(name, value)|
              html_tag :input, type: 'hidden', name: "#{name}_callback", value: value
            end.join('')
          end

          def recaptcha_html(options)
            return '' if options[:recaptcha] != true

            html_tag :input, type: 'hidden', name: 'g-recaptcha-response', id: 'g-recaptcha-response'
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

          def prepare_form_attributes(context, options)
            url         = action_url(context, options)
            attributes  = options.slice(:id, :class, :name, :novalidate)

            { method: 'POST', enctype: 'multipart/form-data' }.merge(attributes).tap do |_attributes|
              _attributes[:action] = url if url
            end
          end

          def action_url(context, options)
            url = options[:action]

            if url.blank?
              if options[:json]
                url = context['path'].blank? ? '/' : context['path']
                url + (url.ends_with?('/') ? 'index.json' : '.json')
              else
                nil
              end
            else
              url = '/' + url unless url.starts_with?('/')
              url_builder(context).prefix(url)
            end
          end

          def url_builder(context)
            context.registers[:services].url_builder
          end

        end

        ::Liquid::Template.register_tag('model_form'.freeze, ModelForm)

      end
    end
  end
end
