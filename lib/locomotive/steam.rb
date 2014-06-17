require 'locomotive/models'
require 'locomotive/decorators'
require 'locomotive/common'

require_relative 'steam/exceptions'
require_relative 'steam/decorators'




require 'sprockets'
require 'sprockets-sass'
require 'haml'
require 'compass'

#require 'httmultiparty'
require 'mime/types'

module Locomotive
  module Steam
    TEMPLATE_EXTENSIONS = %w(liquid haml)
  end
end
