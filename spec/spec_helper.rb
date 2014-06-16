require 'rubygems'
require 'bundler/setup'

require 'locomotive/common'
require 'i18n-spec'
require 'coveralls'

begin
  require 'pry'
rescue LoadError
end


require_relative '../lib/locomotive/steam'
require_relative 'support'

Coveralls.wear!

RSpec.configure do |config|
  config.include Spec::Helpers

  config.filter_run focused: true
  config.run_all_when_everything_filtered = true

  config.before(:all) { remove_logs }
  config.before do
    reset!
    bootstrap_models
  end
  config.after  { reset! }
end
