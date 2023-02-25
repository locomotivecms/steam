require 'rubygems'
require 'bundler/setup'
require 'bundler/gem_tasks'

require 'rake'
require 'rspec'

require_relative 'lib/locomotive/steam'

namespace :mongodb do
  namespace :test do
    desc 'Seed the MongoDB database with the dump of the Sample website'
    task :seed do
      root_path = File.expand_path(File.dirname(__FILE__))
      db_path   = File.join(root_path, 'spec', 'fixtures', 'mongodb')
      if ENV['MONGO_HOST']
        host = "--host=#{ENV['MONGO_HOST']}"
      else
        host = ""
      end

      if database = ENV['DATABASE']
        dump_path = File.join(root_path, 'dump', database)

        `rm -rf #{db_path}`
        `mongodump --db #{database} #{host}`
        `mv #{dump_path} #{db_path}`
      end

      `mongo steam_test_2 --eval "db.dropDatabase()" #{host}`
      `mongorestore -d steam_test_2 #{db_path} #{host}`

      puts "Done! Update now the spec/support/helpers.rb file by setting the new id of the site returned by the mongodb_site_id method"
    end
  end
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new('spec')

RSpec::Core::RakeTask.new('spec:integration') do |spec|
  spec.pattern = 'spec/integration/**/*_spec.rb'
end

RSpec::Core::RakeTask.new('spec:unit') do |spec|
  spec.pattern = 'spec/unit/**/*_spec.rb'
end

task default: ['mongodb:test:seed', :spec]
