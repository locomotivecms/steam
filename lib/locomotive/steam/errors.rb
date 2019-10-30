module Locomotive::Steam

  class NoSiteException < ::Exception
  end

  class RedirectionException < ::Exception

    attr_reader :url, :permanent

    def initialize(url, permanent: false)
      @url        = url
      @permanent  = permanent
      super("Redirect to #{url} (#{permanent ? '301': '302'})")
    end

  end

  class PageNotFoundException < ::Exception
  end

  class TemplateError < ::Liquid::Error

    LINES_RANGE = 10

    attr_accessor :source, :original_backtrace

    def initialize(message, template_name, source, line_number, original_backtrace)
      super(message)
      self.template_name      = template_name
      self.line_number        = line_number
      self.source             = source
      self.original_backtrace = original_backtrace
    end

    def code_lines
      return [] if source.blank? || line_number.nil?

      lines = source.split("\n")

      start   = line_number - (LINES_RANGE / 2)
      start   = 1 if start <= 0
      finish  = line_number + (LINES_RANGE / 2)

      (start..finish).map { |i| [i, lines[i - 1]] }
    end

    def backtrace
      original_backtrace
    end

    private

    def message_prefix
      ""
      # "Liquid parsing error - "
    end

  end

  class LiquidError < TemplateError

    def initialize(error, file, source)
      message     = error.message
      line_number = error.respond_to?(:line_number) ? error.line_number : error.line
      backtrace   = error.backtrace

      super(message, file, source, line_number, backtrace)
    end

  end

  class RenderError < LiquidError

    private

    def message_prefix
      "Render - "
    end

  end

  class JsonParsingError < TemplateError

    def initialize(error, file, source)
      line = if error.message =~ /at line ([0-9]+)/
        $1.to_i
      else
        0
      end

      super(error.message, file, source, line, error.backtrace)
    end

    private

    def message_prefix
      "JSON parsing error - "
    end

  end

  class ActionError < TemplateError

    attr_accessor :action

    def initialize(error, script)
      super(error.message, nil, script, 0, error.backtrace)
    end

    private

    def message_prefix
      "Action error - "
    end

  end

end
