module Locomotive
  module Steam
    module Liquid
      module Tags
        module Concerns

          # The with_scope liquid tag lets the developer use a Ruby syntax to 
          # pass options which is difficult to implement with the Liquid parsing 
          # approach (see the SimpleAttributesParser for instance)
          module AttributesParser
            extend ActiveSupport::Concern

            included do
              # Mongoid operators available on symbols
              OPERATORS = %w(all exists gt gte in lt lte ne nin size near within)

              SYMBOL_OPERATORS_REGEXP = /(\w+\.(#{OPERATORS.join('|')})){1}\s*\:/o
            end
            
            def parse_markup(markup)
              parser = self.class.current_parser

              # 'liquid_code.rb' is purely arbitrary
              source_buffer = ::Parser::Source::Buffer.new('liquid_code.rb')
              source_buffer.source = "{%s}" % clean_markup(markup)

              ast = parser.parse(source_buffer)
              AstProcessor.new.process(ast)
            end

            private

            def clean_markup(markup)
              # convert symbol operators into valid ruby code
              markup.gsub(SYMBOL_OPERATORS_REGEXP, ':"\1" =>')
            end

            class_methods do
              def current_parser
                (@current_parser ||= build_parser).tap do |parser|
                  parser.reset
                end
              end

              def build_parser
                ::Parser::CurrentRuby.new.tap do |parser|
                  # Silent the error instead of logging them to STDERR (default behavior of the parser)
                  parser.diagnostics.consumer = ->(message) { true }
                end
              end
            end

            class AstProcessor
              include AST::Processor::Mixin
              
              def on_hash(node)
                nodes = process_all(node)
                nodes.inject({}) { |memo, sub_hash| memo.merge(sub_hash) }
              end

              def on_pair(node)
                key_expr, right_expr = *node
                { process(key_expr) => process(right_expr) }
              end

              def on_sym(node)
                node.children.first.to_sym
              end

              def on_array(node)
                process_all(node)
              end

              def on_int(node)
                node.children.first.to_i
              end

              def on_float(node)
                node.children.first.to_f
              end

              def on_str(node)
                node.children.first.to_s
              end

              def on_true(node)
                true
              end

              def on_false(node)
                false
              end

              def on_regexp(node)
                regexp_expr, opts_expr = *node
                Regexp.new(process(regexp_expr), process(opts_expr))
              end

              def on_regopt(node)
                node.children ? node.children.join('') : nil
              end

              def on_deep_send(node)
                source_expr, name_expr = *node

                if source_expr.nil?
                  [name_expr.to_s]
                elsif source_expr.type == :send
                  process(source_expr.updated(:deep_send, nil)) << name_expr.to_s
                else
                  raise 'NOT IMPLEMENTED [DEEP_SEND]' # TODO
                end
              end

              def on_send(node)
                source_expr, name_expr = *node

                if source_expr.nil?
                  ::Liquid::Expression.parse(name_expr.to_s)
                elsif name_expr == :+ 
                  process(source_expr)
                elsif source_expr.type == :send
                  ::Liquid::Expression.parse(
                    (process(source_expr.updated(:deep_send, nil)) << name_expr.to_s).join('.')
                  )                
                else
                  raise 'NOT IMPLEMENTED [SEND]' # TODO
                end
              end

              # HACK: override the default process implementation
              def process(node)
                return if node.nil?

                node = node.to_ast

                # Invoke a specific handler
                on_handler = :"on_#{node.type}"
                if respond_to? on_handler
                  new_node = send on_handler, node
                else
                  new_node = handler_missing(node)
                end

                # fix: the original method considered false as nil which is incorrect
                node = new_node unless new_node.nil?

                node
              end
            end
          end
        end
      end
    end
  end
end