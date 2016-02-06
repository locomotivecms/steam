require File.dirname(__FILE__) + '/../integration_helper'

describe 'Site metafields' do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'returns all the values of the site metafields' do
    get '/basic'
    expect(last_response.body).to include 'Color scheme=white'
    expect(last_response.body).to include 'Facebook ID=FB42'
    expect(last_response.body).to include 'Google ID=G42'
    expect(last_response.body).to include 'API URL=https://api.github.com/repos/vmg/redcarpet/issues?state=closed'
    expect(last_response.body).to include 'Expires In=42'
  end

  it 'iterates over the metafields of a namespace' do
    get '/basic'
    expect(last_response.body).to include "<li class='property'>Facebook(facebook_id)=FB42</li>"
    expect(last_response.body).to include "<li class='property'>Google(google_id)=G42</li>"
  end

end
