require 'liquid'
require 'parser/current'
require 'ast'

require_relative 'liquid/errors'
require_relative 'liquid/patches'
require_relative 'liquid/file_system'
require_relative 'liquid/drops/base'
require_relative 'liquid/drops/i18n_base'
require_relative 'liquid/tags/hybrid'
require_relative 'liquid/tags/concerns/section'
require_relative 'liquid/tags/concerns/simple_attributes_parser'
require_relative 'liquid/tags/section'
require_relative_all %w(. drops filters tags/concerns tags), 'liquid'
