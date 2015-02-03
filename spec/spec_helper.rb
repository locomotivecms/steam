# require 'codeclimate-test-reporter'
# CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'

  add_group "Liquid Filters", "lib/locomotive/steam/liquid/filters"
  add_group "Liquid Tags",    "lib/locomotive/steam/liquid/tags"
  add_group "Repositories",   "lib/locomotive/steam/repositories"
  add_group "Services",       "lib/locomotive/steam/services"
end

require 'rubygems'
require 'bundler/setup'

require 'i18n-spec'

# require 'coveralls'
# Coveralls.wear!

require File.join(File.dirname(__FILE__), '../lib/locomotive/steam/repositories')

require_relative '../lib/locomotive/steam'
require_relative 'support'

Locomotive::Steam.configure do |config|
  config.mode = :test
end

RSpec.configure do |config|
  config.include Spec::Helpers

  config.filter_run focused: true
  config.run_all_when_everything_filtered = true

  config.before(:all) { remove_logs }
  config.before { reset! }
  config.after  { reset! }
  config.order = 'random'
end
