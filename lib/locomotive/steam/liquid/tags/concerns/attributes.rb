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
              @attributes     = default || {}
              @raw_attributes = {}
              attribute_markup = ""
              if markup =~ /^ *([a-zA-Z0-9_.]*:.*)$/
                attribute_markup = $1
              elsif markup =~ /^[a-zA-Z0-9 _"']*, *(.*)$/
                attribute_markup = $1
              end
              unless attribute_markup.blank?
                @attributes.merge!(AttributeParser.parse(attribute_markup))
                @raw_attributes = AttributeParser.parse(attribute_markup, raw_mode=true)
              end
            end

            def context_evaluate_array(vals)
              vals.map{ value.is_a?(::Liquid::VariableLookup) ? context.evaluate(value) : value }
            end

            def context_evaluate(vals)
              vals.type
            end

              HashWithIndifferentAccess.new.tap do |hash|
            def evaluate_attributes(context, lax: false)
              @attributes = HashWithIndifferentAccess.new.tap do |hash|
                attributes.each do |key, value|
                  # evaluate the value if possible before casting it
                  _value = value.is_a?(::Liquid::VariableLookup) ? context.evaluate(value) : value

                  hash[key] = cast_value(context, _value, lax: lax)
                end
              end
            end

            def cast_value(context, value, lax: false)
              case value
              when Array          then value.map { |_value| cast_value(context, _value) }
              when Hash           then value.transform_values { |_value| cast_value(context, _value) }
              else
                _value = context.evaluate(value)
                lax && _value.nil? ? value&.name : _value
                _value.respond_to?(:_id) ? _value.send(:_source) : _value
              end
            end

            def tag_attributes_regexp
              ::Liquid::TagAttributes
            end

            class AttributeParser
              class << self
                def parse(markup, raw_mode=false)
                  handle_hash(Parser::CurrentRuby.parse("{#{markup}}"), raw_mode)
                end

                def handle(node, raw_mode=false)
                  handler = "handle_#{node.type}"
                  # TODO create specific error
                  # raise Errno, "unknown expression type: #{node.type.inspect}" unless respond_to?(handler)
                  public_send handler, node, raw_mode
                end

                def handle_hash(node, raw_mode=false)
                  res = {}
                  node.children.each do | n |
                    # evaluate only cast value so the key is always in raw mode
                    res[handle(n.children[0], true)] = handle(n.children[1], raw_mode)
                  end
                  res
                end

                def handle_sym(node, raw_mode=false)
                  node.children[0]
                end

                def handle_int(node, raw_mode=false)
                  node.children[0]
                end

                def handle_str(node, raw_mode=false)
                  node.children[0]
                end

                def handle_regexp(node, raw_mode=false)
                  Unparser.unparse(node)
                end

                def handle_send(node, raw_mode=false)
                  if raw_mode
                    Unparser.unparse(node)
                  else
                    ::Liquid::Expression.parse(Unparser.unparse(node))
                  end
                end

                def handle_true(node, raw_mode=false)
                  true
                end

                def handle_false(node, raw_mode=false)
                  false
                end

                def handle_float(node, raw_mode=false)
                  node.children[0]
                end

                def handle_array(node, raw_mode=false)
                  node.children.map{|n| handle(n, raw_mode)}
                end
              end
            end

          end
        end
      end
    end
  end
end
