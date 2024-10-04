module Locomotive
  module Steam
    module Liquid
      module Tags

        # Filter a collection
        #
        # Usage:
        #
        # {% with_scope main_developer: 'John Doe', providers.in: ['acme'], started_at.le: today, active: true %}
        #   {% for project in contents.projects %}
        #     {{ project.name }}
        #   {% endfor %}
        # {% endwith_scope %}
        #        
        class WithScope < ::Liquid::Block

          include Concerns::AttributesParser
          include Concerns::AttributesEvaluator
          
          SingleVariable = /\A\s*([a-zA-Z_0-9]+)\s*\z/om.freeze
          
          attr_reader :attributes, :attributes_var_name

          def initialize(tag_name, markup, options)
            super

            if markup =~ SingleVariable
              # alright, maybe we'vot got a single variable built
              # with the Action liquid tag instead?
              @attributes_var_name = Regexp.last_match(1)
            elsif markup.present?
              # use our own Ruby parser
              @attributes = parse_markup(markup)
            end

            if attributes.blank? && attributes_var_name.blank?
              raise ::Liquid::SyntaxError.new("Syntax Error in 'with_scope' - Valid syntax: with_scope <name_1>: <value_1>, ..., <name_n>: <value_n>")
            end
          end

          def render(context)
            context.stack do
              context['with_scope'] = evaluate_attributes(context)

              # for now, no content type is assigned to this with_scope
              context['with_scope_content_type'] = false

              super
            end
          end
        end

        ::Liquid::Template.register_tag('with_scope'.freeze, WithScope)
      end
    end
  end
end