require 'simplecov'
require 'codeclimate-test-reporter'
require 'coveralls'

SimpleCov.start do
  formatter SimpleCov::Formatter::MultiFormatter[
    SimpleCov::Formatter::HTMLFormatter,
    CodeClimate::TestReporter::Formatter,
    Coveralls::SimpleCov::Formatter
  ]

  add_filter 'config/'
  add_filter 'example/'
  add_filter 'spec/'

  add_group "Middlewares",    "lib/locomotive/steam/middlewares"
  add_group "Liquid",         "lib/locomotive/steam/liquid"
  add_group "Adapters",       "lib/locomotive/steam/adapters"
  add_group "Entities",       "lib/locomotive/steam/entities"
  add_group "Repositories",   "lib/locomotive/steam/repositories"
  add_group "Services",       "lib/locomotive/steam/services"
end

require 'rubygems'
require 'bundler/setup'

require 'i18n-spec'

require_relative '../lib/locomotive/steam'
# TODO
# require_relative '../lib/locomotive/steam/repositories/filesystem'
require_relative 'support'

Locomotive::Steam.configure do |config|
  config.mode = :test
end

RSpec.configure do |config|
  config.include Spec::Helpers

  config.filter_run focused: true
  config.run_all_when_everything_filtered = true

  config.before(:all) { remove_logs; setup_common }
  config.before { reset! }
  config.after  { reset! }
  config.order = 'random'
end
