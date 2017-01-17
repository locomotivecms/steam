module Locomotive::Steam

  class NoSiteException < ::Exception
  end

  class RedirectionException < ::Exception

    attr_reader :url

    def initialize(url)
      @url = url
      super("Redirect to #{url}")
    end

  end

  class ParsingRenderingError < ::StandardError

    LINES_RANGE = 10

    attr_accessor :file, :line, :source, :original_backtrace

    def initialize(message, file, source, line, original_backtrace)
      @file, @source, @line, @original_backtrace = file, source, line, original_backtrace
      super(message)
    end

    def code_lines
      return [] if source.blank? || line.nil?

      lines = source.split("\n")

      start   = line - (LINES_RANGE / 2)
      start   = 1 if start <= 0
      finish  = line + (LINES_RANGE / 2)

      (start..finish).map { |i| [i, lines[i - 1]] }
    end

    def backtrace
      original_backtrace
    end

  end

  class RenderError < ParsingRenderingError

    def initialize(error, file, source)
      message   = error.message
      line      = error.respond_to?(:line_number) ? error.line_number : error.line
      backtrace = error.backtrace

      super(message, file, source, line, backtrace)
    end

  end

  class ActionError < ParsingRenderingError

    attr_accessor :action

    def initialize(error, script)
      super(error.message, nil, script, 0, error.backtrace)
    end

  end

end
