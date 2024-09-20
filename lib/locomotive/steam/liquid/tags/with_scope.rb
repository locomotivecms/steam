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

        # s(:hash,
        #   s(:pair,
        #     s(:sym, :key),
        #     s(:array,
        #       s(:int, 1),
        #       s(:int, 2),
        #       s(:int, 3))))
        class WithScope < ::Liquid::Block

          class HashProcessor
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
              # pp node.location
              # pp node.location.expression.source

              ::Liquid::Expression.parse(node.location.expression.source)

              # raise 'TODO'

              # source_expr, name_expr = *node

              # if source_expr.nil?
              #   ::Liquid::Expression.parse(name_expr.to_s)
              # elsif source_expr.type == :send
              #   ::Liquid::Expression.parse(
              #     (process(source_expr.updated(:deep_send, nil)) << name_expr.to_s).join('.')
              #   )                
              # else
              #   raise 'NOT IMPLEMENTED [SEND]' # TODO
              # end
            end

            # TODO: create our own mixin
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

              node = new_node unless new_node.nil?

              node
            end
          end

          include Concerns::Attributes

          # Regexps and Arrays are allowed
          ArrayFragment         = /\[(\s*(#{::Liquid::QuotedFragment},\s*)*#{::Liquid::QuotedFragment}\s*)\]/o.freeze
          RegexpFragment        = /\/([^\/]+)\/([imx]+)?/o.freeze
          StrictRegexpFragment  = /\A#{RegexpFragment}\z/o.freeze

          # a slight different from the Shopify implementation because we allow stuff like `started_at.le`
          TagAttributes   = /([a-zA-Z_0-9\.]+)\s*\:\s*(#{ArrayFragment}|#{RegexpFragment}|#{::Liquid::QuotedFragment})/o.freeze
          # SingleVariable  = /(#{::Liquid::VariableSignature}+)/om.freeze
          SingleVariable = /\A\s*([a-zA-Z_0-9]+)\s*\z/om.freeze

          REGEX_OPTIONS = {
            'i' => Regexp::IGNORECASE,
            'm' => Regexp::MULTILINE,
            'x' => Regexp::EXTENDED
          }.freeze

          OPERATORS = %w(all exists gt gte in lt lte ne nin size near within)

          SYMBOL_OPERATORS_REGEXP = /(\w+\.(#{OPERATORS.join('|')})){1}\s*\:/o

          attr_reader :attributes, :attributes_var_name, :ast

          def initialize(tag_name, markup, options)

            super

            # convert symbol operators into valid ruby code
            markup.gsub!(SYMBOL_OPERATORS_REGEXP, ':"\1" =>')

            # pp markup

            if markup =~ SingleVariable
              # puts "HERE?"
              # alright, maybe we'vot got a single variable built
              # with the Action liquid tag instead?
              @attributes_var_name = Regexp.last_match(1)
            elsif markup.present?
              # ast = Parser::CurrentRuby.parse("{%s}" % markup)
              # pp ast
              # @attributes = HashProcessor.new.process(ast)
              # puts "-----"
              # pp @attributes
              @attributes = parse_markup(markup)
            end

            if attributes.blank? && attributes_var_name.blank?
              raise ::Liquid::SyntaxError.new("Syntax Error in 'with_scope' - Valid syntax: with_scope <name_1>: <value_1>, ..., <name_n>: <value_n>")
            end

            # raise 'TODO'

            # # simple hash?
            # parse_attributes(markup) { |value| parse_attribute(value) }

            # if attributes.empty? && markup =~ SingleVariable
            #   # alright, maybe we'vot got a single variable built
            #   # with the Action liquid tag instead?
            #   @attributes_var_name = Regexp.last_match(1)
            # end

            # if attributes.empty? && attributes_var_name.blank?
            #   raise ::Liquid::SyntaxError.new("Syntax Error in 'with_scope' - Valid syntax: with_scope <name_1>: <value_1>, ..., <name_n>: <value_n>")
            # end
          end

          def render(context)
            pp attributes if ENV['WITH_SCOPE_DEBUG']
            context.stack do
              context['with_scope'] = self.evaluate_attributes(context)

              # for now, no content type is assigned to this with_scope
              context['with_scope_content_type'] = false

              super
            end
          end

          protected

          def parse_markup(markup)
            # begin
            parser = nil
            ast = nil
            source_buffer = nil

              puts "init:" 
              puts Benchmark.measure { parser = Parser::CurrentRuby.new }
              # Silent the error instead of logging them to STDERR (default behavior of the parser)

              puts "consumer:"
              puts Benchmark.measure { parser.diagnostics.consumer = ->(message) { true } }
              
              # 'with_scope.rb' is purely arbitrary
              puts "source_buffer:"
              puts Benchmark.measure { source_buffer = Parser::Source::Buffer.new('with_scope.rb') }
              
              source_buffer.source = "{%s}" % markup
              
              puts "ast: "
              puts Benchmark.measure { ast = parser.parse(source_buffer) }

              foo = nil
              puts "visit ast: "
              puts Benchmark.measure { foo = HashProcessor.new.process(ast) }
              foo
            # rescue StandardError => e
              # TODO: log something???
              # {}
            # end
          end

          # def parse_attribute(value)
          #   case value
          #   when StrictRegexpFragment
          #     # let the cast_value attribute create the Regexp (done during the rendering phase)
          #     value
          #   when ArrayFragment
          #     $1.split(',').map { |_value| parse_attribute(_value) }
          #   else
          #     ::Liquid::Expression.parse(value)
          #   end
          # end

          def evaluate_attributes(context)
            @attributes = context[attributes_var_name] || {} if attributes_var_name.present?

            attributes.inject({}) do |memo, (key, value)|
              # _slug instead of _permalink
              _key = key.to_s == '_permalink' ? '_slug' : key.to_s

              # puts [_key, evaluate_attribute(context, value)]

              memo.merge({ _key => evaluate_attribute(context, value) })
            end
          end

          def evaluate_attribute(context, value)
            # pp "evaluate_attribute = #{value}"
            case value
            when Array 
              value.map { |v| evaluate_attribute(context, v) }
            when Hash
              Hash[value.map { |k, v| [k.to_s, evaluate_attribute(context, v)] }]
            when ::Liquid::VariableLookup
              evaluated_value = context.evaluate(value)
              evaluated_value.respond_to?(:_id) ? evaluated_value.send(:_source) : evaluate_attribute(context, evaluated_value)
            when StrictRegexpFragment
              create_regexp($1, $2)
            else 
              value
            end
          end

          # def evaluate_attributes(context)
          #   @attributes = context[attributes_var_name] || {} if attributes_var_name.present?

          #   HashWithIndifferentAccess.new.tap do |hash|
          #     attributes.each do |key, value|
          #       # _slug instead of _permalink
          #       _key = key.to_s == '_permalink' ? '_slug' : key.to_s

          #       # evaluate the value if possible before casting it
          #       _value = value.is_a?(::Liquid::VariableLookup) ? context.evaluate(value) : value

          #       hash[_key] = cast_value(context, _value)
          #     end
          #   end
          # end

          # def cast_value(context, value)
          #   case value
          #   when Array                then value.map { |_value| cast_value(context, _value) }
          #   when StrictRegexpFragment then create_regexp($1, $2)
          #   else
          #     _value = context.evaluate(value)
          #     _value.respond_to?(:_id) ? _value.send(:_source) : _value
          #   end
          # end

          def create_regexp(value, unparsed_options)
            options = unparsed_options.blank? ? nil : unparsed_options.split('').uniq.inject(0) do |_options, letter|
              _options |= REGEX_OPTIONS[letter]
            end
            Regexp.new(value, options)
          end

          def tag_attributes_regexp
            TagAttributes
          end
        end

        ::Liquid::Template.register_tag('with_scope'.freeze, WithScope)

      end
    end
  end
end