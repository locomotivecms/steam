require 'solid'
require 'locomotive/mounter'

require_relative 'liquid/scopeable'
require_relative 'liquid/drops/base'
require_relative 'liquid/tags/hybrid'
require_relative 'liquid/tags/path_helper'

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
