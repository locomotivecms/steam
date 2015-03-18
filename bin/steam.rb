#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'thin'
require 'optparse'

server_options = { address: 'localhost', port: 8080 }

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
    options[:asset_path] = File.expand_path(File.join(path, 'public'))
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
    options[:asset_path] = path
  end

  # Asset host
  opts.on('-h', '--asset-host HOST', 'Required if the assets are stored on Amazon S3 or through a CDN') do |host|
    options[:asset_host]
  end

  # TCP port
  opts.on('-p', '--port PORT', 'Run the HTTP server on the specified port (by default: 8080') do |port|
    server_options[:port] = port
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
  config.serve_assets   = options[:asset_path].present?
  config.asset_path     = options[:asset_path]
  config.asset_host     = options[:asset_host]
  config.mounted_on     = options[:mounted_on]
  config.minify_assets  = false
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config.notifier = Locomotive::Common::Logger.setup(options[:log_file])
end

app = Locomotive::Steam::Server.to_app

# Note: alt thin settings (Threaded)
server = Thin::Server.new(server_options[:address], server_options[:port], app)
server.threaded = true
server.start
# FIXME: Rack::Handler::Thin.run app (not threaded)

# WEBRick rack handler
# Rack::Handler::WEBrick.run app

Locomotive::Common::Logger.info 'Server started...'
