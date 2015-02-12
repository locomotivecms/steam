require 'solid'

require_relative 'liquid/errors'
require_relative 'liquid/patches'
require_relative 'liquid/drops/base'
require_relative 'liquid/drops/i18n_base'
require_relative 'liquid/drops/proxy_collection'
require_relative 'liquid/tags/hybrid'
require_relative_all %w(. drops filters tags/concerns tags), 'liquid'
