#!/usr/bin/env ruby

require 'thin'

DIR = File.expand_path(File.dirname(__FILE__))

require File.join(DIR, '../lib/steam')
require File.join(DIR, '../lib/locomotive/steam/server')
require File.join(DIR, '../lib/locomotive/steam/initializers')

path = ENV['SITE_PATH'] || File.join(DIR, '../spec/fixtures/default')
Locomotive::Steam::Logger.setup(path, false)
reader = Locomotive::Mounter::Reader::FileSystem.instance
reader.run!(path: path)

app = Locomotive::Steam::Server.new(reader, {
  serve_assets: true
})

server  = Thin::Server.new('localhost', '3333', app)
server.threaded = true
server.start