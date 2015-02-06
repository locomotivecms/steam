require 'solid'

require_relative 'liquid/errors'
require_relative 'liquid/patches'
require_relative 'liquid/drops/base'
require_relative 'liquid/drops/proxy_collection'
require_relative 'liquid/tags/hybrid'
require_relative 'liquid/tags/path_helper'

# %w{. drops tags filters}.each do |dir|
%w{. drops filters tags}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end
