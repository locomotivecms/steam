require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'renders an image' do
    get '/images/nav_on.png'
    expect(last_response.status).to eq(200)
  end

  it 'renders a stylesheet' do
    get '/stylesheets/application.css'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match('body{background:#f0eee3')
  end

  it 'renders a SCSS asset' do
    get '/stylesheets/other/style.css'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match('body{background:red}')
  end

end
