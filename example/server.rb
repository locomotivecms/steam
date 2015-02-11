#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'thin'

require_relative '../lib/locomotive/steam'
require_relative '../lib/locomotive/steam/server'

path = ENV['SITE_PATH'] || File.join(File.expand_path(File.dirname(__FILE__)), '../spec/fixtures/default')

Locomotive::Steam.configure do |config|
  config.mode = :test
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  config.notifier = Locomotive::Common::Logger.setup(File.join(path, 'log/steam.log'))
end

server = Locomotive::Steam::Server.new(path: path)

# Note: alt thin settings
# server = Thin::Server.new('localhost', '3333', foo)
# server.threaded = true

Rack::Handler::Thin.run server.to_app

Locomotive::Common::Logger.info 'Server started...'
server.start
