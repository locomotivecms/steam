require 'solid'
require 'locomotive/mounter'
require 'locomotive/steam/liquid/scopeable'
require 'locomotive/steam/liquid/drops/base'
require 'locomotive/steam/liquid/tags/hybrid'
require 'locomotive/steam/liquid/tags/path_helper'

%w{. drops tags filters}.each do |dir|
  Dir[File.join(File.dirname(__FILE__), 'liquid', dir, '*.rb')].each { |lib| require lib }
end

# add to_liquid methods to main models from the mounter
%w{site page content_entry}.each do |name|
  klass = "Locomotive::Mounter::Models::#{name.classify}".constantize

  klass.class_eval <<-EOV
    def to_liquid
      ::Locomotive::Steam::Liquid::Drops::#{name.classify}.new(self)
    end
  EOV
end
