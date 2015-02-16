require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'converts {{ page.templatized? }} => true on templatized page' do
    get '/songs/song-number-1'
    expect(last_response.body).to include "templatized='true'"
  end

  it 'converts {{ page.templatized? }} => false on regular page' do
    get '/index'
    expect(last_response.body).to include "templatized='false'"
  end

  it 'converts {{ page.listed? }} => true on listed page' do
    get '/music'
    expect(last_response.body).to include "listed='true'"
  end

  it "provides an access to page's content_type collection" do
    get '/songs/song-number-1'
    expect(last_response.body).to include "content_type_size='8'"
  end

  it 'provides count alias on collections' do
    get '/songs/song-number-1'
    expect(last_response.body).to include "content_type_count='8'"
  end

  describe '.link_to' do

    it 'writes a link to a page' do
      get '/events'
      expect(last_response.body).to include 'Discover: <a href="/music">Music</a>'
    end

    it "writes a localized a link" do
      get '/events'
      expect(last_response.body).to include 'Plus à notre sujet: <a href="/fr/a-notre-sujet">Qui sommes nous ?</a>'
    end

    it "writes a link to a page with a custom label" do
      get '/events'
      expect(last_response.body).to include 'More about us: <a href="/about-us">Who are we ?</a>'
    end

    it "writes a link to a templatized page" do
      get '/events'
      expect(last_response.body).to include '<a href="/songs/song-number-1">Song #1</a>'
    end

    it "writes a link to a templatized page with a different handle" do
      get '/events'
      expect(last_response.body).to include '<a href="/songs/song-number-8">Song #8</a>'
    end

  end

end
