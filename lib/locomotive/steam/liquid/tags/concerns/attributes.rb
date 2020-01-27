require 'parser/current'
require 'unparser'

module Locomotive
  module Steam
    module Liquid
      module Tags
        module Concerns

          # Many of Liquid tags have attributes (like options)
          # This module makes sure we use the same reliable way to
          # extract and evaluate them.

          module Attributes

            attr_reader :attributes, :raw_attributes

            private

            def parse_attributes(markup, default = {})
              @raw_attributes = default || {}
              attribute_markup = ""
              if markup =~ /^ *([a-zA-Z0-9_.]*:.*)$/
                attribute_markup = $1
              elsif markup =~ /^[a-zA-Z0-9 _"']*, *(.*)$/
                attribute_markup = $1
              end
              unless attribute_markup.blank?
                @raw_attributes.merge!(AttributeParser.parse(attribute_markup))
              end
              @raw_attributes
            end

            def context_evaluate_array(vals)
              vals.map{ value.is_a?(::Liquid::VariableLookup) ? context.evaluate(value) : value }
            end

            def context_evaluate(vals)
              vals.type
            end

            def evaluate_attributes(context, lax: false)
              @attributes = HashWithIndifferentAccess.new.tap do |hash|
                raw_attributes.each do |key, value|
                  hash[evaluate_value(context, key, lax: lax)] = evaluate_value(context, value, lax: lax)
                end
              end
            end

            def evaluate_value(context, value, lax: false)
              case value
              when ::Liquid::VariableLookup
                _value = context.evaluate(value)
                lax && _value.nil? ? value&.name : _value
              when Array          then value.map { |_value| evaluate_value(context, _value) }
              when Hash           then value.transform_values { |_value| evaluate_value(context, _value) }
              else
                value
              end
            end

            def tag_attributes_regexp
              ::Liquid::TagAttributes
            end

            class AttributeParser
              class << self
                def parse(markup)
                  handle_hash(Parser::CurrentRuby.parse("{#{markup}}"), )
                end

                def handle(node)
                  handler = "handle_#{node.type}"
                  unless respond_to?(handler)
                    raise ::Liquid::SyntaxError.new(
                      "Fail to parse attributes. Unknown expression type: #{node.type.inspect}")
                  end
                  public_send handler, node
                end

                def handle_hash(node)
                  res = {}
                  node.children.each do | n |
                    res[handle(n.children[0])] = handle(n.children[1])
                  end
                  res
                end

                def handle_sym(node)
                  node.children[0]
                end

                def handle_int(node)
                  node.children[0]
                end

                def handle_str(node)
                  node.children[0]
                end

                def handle_regexp(node)
                  Unparser.unparse(node)
                end

                def handle_send(node)
                  ::Liquid::Expression.parse(Unparser.unparse(node))
                end

                def handle_true(node)
                  true
                end

                def handle_false(node)
                  false
                end

                def handle_float(node)
                  node.children[0]
                end

                def handle_array(node)
                  node.children.map{|n| handle(n)}
                end
              end
            end

          end
        end
      end
    end
  end
end
