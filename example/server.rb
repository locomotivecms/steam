#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'

Bundler.require

require 'thin'
require 'common'

require_relative '../lib/steam'
require_relative '../lib/locomotive/steam/server'
require_relative '../lib/locomotive/steam/initializers'

path = File.join(File.expand_path(File.dirname(__FILE__)), '../spec/fixtures/default')

reader = Locomotive::Mounter::Reader::FileSystem.instance
reader.run!(path: path)

app = Locomotive::Steam::Server.new(reader, {
  serve_assets: true
})

server  = Thin::Server.new('localhost', '3333', app)
server.threaded = true

Locomotive::Common::Logger.info 'Server started...'
server.start