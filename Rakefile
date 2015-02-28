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
RSpec::Core::RakeTask.new('spec') do |spec|
  spec.exclude_pattern = 'spec/unit/liquid/**/*_spec.rb,spec/integration/server/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:integration') do |spec|
  # spec.pattern = 'spec/integration/**/*_spec.rb'
  spec.pattern = 'spec/integration/{mongodb,repositories}/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:unit') do |spec|
  # spec.pattern = 'spec/unit/**/*_spec.rb'
  spec.pattern = 'spec/unit/{services,core_ext,middlewares,decorators,adapters,entities,models,repositories}/**/*_spec.rb'
  # spec.pattern = 'spec/unit/{adapters,entities,models,repositories}/**/*_spec.rb'
end

task default: :spec
