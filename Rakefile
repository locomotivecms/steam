require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rake'
require 'rspec'

# === Gems install tasks ===
Bundler::GemHelper.install_tasks

# require 'coveralls/rake/task'
# Coveralls::RakeTask.new

require_relative 'lib/locomotive/steam'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

RSpec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = 'spec/unit/**/*_spec.rb'
end

task default: :spec
