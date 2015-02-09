module Liquid
  module StandardFilters

    private

    # Fixme: Handle DateTime, Date and Time objects, convert them
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
end

module Liquid
  module OptionsBuilder

    private

    def parse_options_from_string(string)
      string.try(:strip!)

      return nil if string.blank?

      string = string.gsub(/^(\s*,)/, '')
      Solid::Arguments.parse(string)
    end

    def interpolate_options(options, context)
      if options
        options.interpolate(context).first
      else
        {}
      end
    end

  end
end

Liquid::Tag.send(:include, Liquid::OptionsBuilder)
