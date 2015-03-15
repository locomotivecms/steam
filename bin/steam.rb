#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'thin'
require 'optparse'

options = {
  adapter:  {
    name:   :filesystem,
    path:   ENV['SITE_PATH'] || File.join(File.dirname(__FILE__), '../spec/fixtures/default')
  },
  log_file: nil
}

OptionParser.new do |opts|
  opts.banner = 'Usage: steam.rb [options]'

  # Filesystem adapter
  opts.on('-p', '--path PATH', 'Serve a Wagon site from a path in your filesystem') do |path|
    options[:adapter][:path] = File.expand_path(path)
    options[:assets_path] = File.expand_path(File.join(path, 'public'))
    options[:database] = options[:hosts] = nil
  end

  # MongoDB adapter
  opts.on('-d', '--database DATABASE', 'Serve a Wagon site from a MongoDB database') do |database|
    options[:adapter].merge!(name: :'mongoDB', database: database)
    options[:adapter][:hosts] ||= ['127.0.0.1']
    options[:adapter].delete(:path)
  end
  opts.on('--hosts x,y,z', Array, 'Specify the MongoDB hosts') do |hosts|
    options[:adapter][:hosts] = hosts
  end

  # Assets path
  opts.on('-a', '--assets-path ASSETS_PATH', 'Tell Steam where to find the assets (if local)') do |path|
    options[:assets_path] = path
  end

  # Logger
  opts.on('-l', '--log-file LOG_FILE', 'Log file of the Steam server') do |file|
    options[:log_file] = File.expand_path(file)
  end

  # Help
  opts.on_tail('-h', '--help', 'Show this message') do
    puts opts
    exit
  end

end.parse!

require_relative '../lib/locomotive/steam'
require_relative '../lib/locomotive/steam/server'

Locomotive::Steam.configure do |config|
  config.mode           = :test
  config.adapter        = options[:adapter]
  config.serve_assets   = options[:assets_path].present?
  config.assets_path    = options[:assets_path]
  config.minify_assets  = false
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config.notifier = Locomotive::Common::Logger.setup(options[:log_file])
end

app = Locomotive::Steam::Server.to_app

# Note: alt thin settings (Threaded)
server = Thin::Server.new('localhost', '8080', app)
server.threaded = true
server.start
# FIXME: Rack::Handler::Thin.run app (not threaded)

# WEBRick rack handler
# Rack::Handler::WEBrick.run app

Locomotive::Common::Logger.info 'Server started...'
