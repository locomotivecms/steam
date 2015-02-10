#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'thin'

require_relative '../lib/locomotive/steam'
require_relative '../lib/locomotive/steam/server'

path = ENV['SITE_PATH'] || File.join(File.expand_path(File.dirname(__FILE__)), '../spec/fixtures/default')

# reader = Locomotive::Mounter::Reader::FileSystem.instance
# reader.run!(path: path)

# datastore = Locomotive::Steam::FileSystemDatastore.new(path: path)

# app = Locomotive::Steam::Server.new(datastore, {
#   serve_assets: true
# })

Locomotive::Steam.configure do |config|
  config.mode = :test
end

Locomotive::Common.reset
Locomotive::Common.configure do |config|
  path = File.join(path, 'log/steam.log')
  config.notifier = Locomotive::Common::Logger.setup(path)
end

server = Locomotive::Steam::Server.new(path: path)

# THIN
# server = Thin::Server.new('localhost', '3333', foo)
# server.threaded = true

Rack::Handler::WEBrick.run server.to_app

Locomotive::Common::Logger.info 'Server started...'
server.start
