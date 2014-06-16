require_relative 'steam/version'
require_relative 'steam/exceptions'

require 'sprockets'
require 'sprockets-sass'
require 'haml'
require 'compass'

require 'httmultiparty'
require 'mime/types'

module Locomotive
  module Steam
    TEMPLATE_EXTENSIONS = %w(liquid haml)
  end
end
