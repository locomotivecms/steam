#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'thin'

require_relative '../lib/locomotive/steam'
require_relative '../lib/locomotive/steam/server'

path = File.expand_path(ARGV[0] || ENV['SITE_PATH'] || File.join(File.dirname(__FILE__), '../spec/fixtures/default'))

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

app = Locomotive::Steam::Server.to_app

# Note: alt thin settings (Threaded)
server = Thin::Server.new('localhost', '8080', app)
server.threaded = true
server.start
# FIXME: Rack::Handler::Thin.run app (not threaded)

# WEBRick rack handler
# Rack::Handler::WEBrick.run app

Locomotive::Common::Logger.info 'Server started...'

