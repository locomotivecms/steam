require 'rubygems'
require 'bundler/setup'

require 'rake'
require 'rspec'

require 'rspec/core/rake_task'

require_relative 'lib/steam'

RSpec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
end

task spec: ['spec:integration']

task default: :spec