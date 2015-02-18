#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'thin'

require_relative '../lib/locomotive/steam'
require_relative '../lib/locomotive/steam/server'

path = ARGV[0] || ENV['SITE_PATH'] || File.join(File.expand_path(File.dirname(__FILE__)), '../spec/fixtures/default')

Locomotive::Steam.configure do |config|
  config.mode           = :test
  config.site_path      = path
  config.serve_assets   = true
  config.minify_assets  = false
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config.notifier = Locomotive::Common::Logger.setup(File.join(path, 'log/steam.log'))
end

server = Locomotive::Steam::Server.new

# Note: alt thin settings (Threaded)
server = Thin::Server.new('localhost', '8080', server.to_app)
server.threaded = true
server.start
# FIXME: Rack::Handler::Thin.run server.to_app (not threaded)

# WEBRick rack handler
# Rack::Handler::WEBrick.run server.to_app

Locomotive::Common::Logger.info 'Server started...'

