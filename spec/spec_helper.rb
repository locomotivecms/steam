require_relative '../lib/steam'

require 'rubygems'
require 'bundler/setup'

require 'i18n-spec'
require 'coveralls'
Coveralls.wear!

require_relative 'support'

RSpec.configure do |c|
  c.filter_run focused: true
  c.run_all_when_everything_filtered = true
  c.include Spec::Helpers
  c.before(:all) { remove_logs }
  c.before { reset! }
  c.after  { reset! }
end