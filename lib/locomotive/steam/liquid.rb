require 'solid'
# require 'locomotive/models'

# require_relative 'liquid/scopeable'
require_relative 'liquid/asset_host'
require_relative 'liquid/errors'
require_relative 'liquid/patches'
require_relative 'liquid/drops/base'
# require_relative 'liquid/tags/hybrid'
# require_relative 'liquid/tags/path_helper'

# %w{. drops tags filters}.each do |dir|
%w{. filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end
