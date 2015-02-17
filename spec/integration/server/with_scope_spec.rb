require File.dirname(__FILE__) + '/../integration_helper'

describe 'Complex with_scope conditions' do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'returns the right number of events' do
    get '/filtered'
    expect(last_response.body).to include 'events=1'
  end

  it 'returns the right number of bands' do
    get '/filtered'
    expect(last_response.body).to include 'bands=2'
  end

  it 'returns the first band in the right order' do
    get '/filtered'
    expect(last_response.body).to include "first event=Browne's Market"
  end

  it 'returns the right number of events' do
    get '/filtered'
    expect(last_response.body).to include 'events=1'
  end

  it 'evaluates collection when called all inside of scope' do
    get '/music'
    expect(last_response.body).to include "<p class='scoped_song'>Song #3"
    expect(last_response.body).to match /<p class='scoped_song_link'>\s+<a href='\/songs\/song-number-3'>Song #3<\/a>/m
  end

  it 'size of evaluated unscoped collection equal to unevaluated one' do
    get '/music'
    expect(last_response.body).to include "class='collection_equality'>8=8"
  end

end
