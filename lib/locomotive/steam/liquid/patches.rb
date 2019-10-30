module Liquid
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

  class ParseContext

    def merge(options)
      @template_options.merge(options)
    end

  end

  class PartialCache

    class << self
      alias_method :load_without_catching_exception, :load
    end

    # FIXME: can't find a better way to handle this
    def self.load(template_name, context:, parse_context:)
      begin
        load_without_catching_exception(template_name, context: context, parse_context: parse_context)
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
