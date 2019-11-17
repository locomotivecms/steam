# Enhance the IF condition to write the following statement:
#
# {% if value is present %}Value is not blank{% endif %}
#
Liquid::Condition.operators['is'.freeze] = lambda { |cond, left, right|  cond.send(:equal_variables, left, right) }

module Liquid

  class Expression

    class << self
      alias_method :parse_without_extra_literals, :parse
    end

    EXTRA_LITERALS = {
      'present' => MethodLiteral.new(:present?, '').freeze
    }.freeze

    def self.parse(markup)
      if EXTRA_LITERALS.key?(markup)
        EXTRA_LITERALS[markup]
      else
        parse_without_extra_literals(markup)
      end
    end

  end

  class ParseContext

    def []=(option_key, value)
      @options[option_key] = value
    end

    def merge(options)
      @template_options.merge(options)
    end

  end

  module StandardFilters

    private

    # FIXME: Handle DateTime, Date and Time objects, convert them
    # into seconds (integer)
    def to_number(obj)
      case obj
      when Numeric
        obj
      when String
        (obj.strip =~ /^\d+\.\d+$/) ? obj.to_f : obj.to_i
      when DateTime, Date, Time
        obj.to_time.to_i
      else
        0
      end
    end

  end

  class PartialCache

    def self.load(template_name, context:, parse_context:)
      begin
        cached_partials = (context.registers[:cached_partials] ||= {})
        cached = cached_partials[template_name]
        return cached if cached

        file_system = (context.registers[:file_system] ||= ::Liquid::Template.file_system)
        source = file_system.read_template_file(template_name)
        parse_context.partial = true

        partial = ::Liquid::Template.parse(source, parse_context)
        cached_partials[template_name] = partial


      rescue ::Liquid::SyntaxError => e
        # FIXME: we had to reload the template one more time. Not ideal.
        file_system = (context.registers[:file_system] ||= ::Liquid::Template.file_system)
        source = file_system.read_template_file(template_name)
        raise Locomotive::Steam::LiquidError.new(e, template_name, source)
      end
    ensure
      parse_context.partial = false
    end

  end
end
