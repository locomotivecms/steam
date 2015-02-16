require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'Static assets' do

    it 'renders an image' do
      get '/images/nav_on.png'
      expect(last_response.status).to eq(200)
    end

  end

  describe 'Dynamic assets (SCSS + Coffeescript)' do

    it 'renders a stylesheet' do
      get '/stylesheets/application.css'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('body{background:#f0eee3')
    end

    it 'renders a SCSS asset' do
      get '/stylesheets/other/style.css'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('body{background:red}')
    end

    it 'renders a Coffeescript asset' do
      get '/javascripts/application.js'
      expect(last_response.status).to eq(200)
      expect(last_response.body).to include('alert("hello world")')
    end

  end

end
