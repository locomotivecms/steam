module Locomotive::Steam

  class NoSiteException < ::Exception
  end

  class RenderError < ::StandardError

    LINES_RANGE = 10

    attr_reader :file, :source, :line, :original_backtrace

    def initialize(message, file, source, line, original_backtrace)
      @file, @source, @line, @original_backtrace = file, source, line, original_backtrace
      super(message)
    end

    def code_lines
      return [] if source.blank? || line.nil?

      lines = source.split("\n")

      start   = line - (LINES_RANGE / 2)
      start   = 0 if start < 0
      finish  = line + (LINES_RANGE / 2)

      (start..finish).map { |i| [i, lines[i]] }
    end

    def backtrace
      original_backtrace
    end

  end

end
