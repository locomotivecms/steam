require_relative '../lib/steam'

require 'rspec'
require 'launchy'
require 'pry'

Dir["#{File.expand_path('../support', __FILE__)}/*.rb"].each do |file|
  require file
end

RSpec.configure do |c|
  c.filter_run focused: true
  c.run_all_when_everything_filtered = true
  c.include Spec::Helpers
  c.before(:all) { remove_logs }
  c.before { reset! }
  c.after  { reset! }
end