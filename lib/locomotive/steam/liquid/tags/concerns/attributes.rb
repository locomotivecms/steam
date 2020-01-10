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

            def handle(node)
              handler = "handle_#{node.type}"
              # TODO create specific error
              # raise Errno, "unknown expression type: #{node.type.inspect}" unless respond_to?(handler)
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

            private

            def parse_attributes(markup, default = {})
              @attributes     = default || {}
              @raw_attributes = {}

              return if markup.blank?
              return if markup.scan(tag_attributes_regexp).size == 0
              node = Parser::CurrentRuby.parse("{#{markup}}")
              @attributes = handle(node)
            end

            def context_evaluate_array(vals)
              vals.map{ value.is_a?(::Liquid::VariableLookup) ? context.evaluate(value) : value }
            end

            def context_evaluate(vals)
                vals.type
            end

            def evaluate_attributes(context, lax: false)
              HashWithIndifferentAccess.new.tap do |hash|
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

          end

        end
      end
    end
  end
end
