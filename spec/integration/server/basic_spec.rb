require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'shows the index page' do
    get '/index'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/Upcoming events/)
  end

  describe 'Page not found' do

    it 'shows the 404 page' do
      get '/void'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include 'page not found'
    end

    it 'shows the 404 page with a 404 status code when its called explicitly' do
      get '/404'
      expect(last_response.status).to eq(404)
      expect(last_response.body).to include 'page not found'
    end

  end

  it 'shows content' do
    get '/about-us/jane-doe'
    expect(last_response.body).to include '<link href="/stylesheets/application.css"'
    expect(last_response.body).to include 'Lorem ipsum dolor sit amet'
  end

  describe 'snippets' do

    it 'includes a basic snippet' do
      get '/'
      expect(last_response.body).to include 'All photos are licensed under Creative Commons.'
    end

    it 'includes a snippet whose name is composed of dash' do
      get '/'
      expect(last_response.body).to include '<p>A complicated one name indeed.</p>'
    end

  end

  describe 'templatized page' do

    it 'shows a content type template' do
      get '/songs/song-number-1'
      expect(last_response.body).to include 'Song #1'
    end

    it 'renders a page under a templatized one' do
      get '/songs/song-number-1/band'
      expect(last_response.body).to include 'Song #1'
      expect(last_response.body).to include 'Leader: Eddie'
    end

  end

  describe 'translations' do

    it 'translates strings' do
      get '/en'
      expect(last_response.body).to include 'Powered by'
      get '/fr'
      expect(last_response.body).to include 'Propulsé par'
    end

    it 'provides translation in scopes' do
      get '/'
      expect(last_response.body).to match /scoped_translation=.French./
    end

    it 'translates a page with link_to tags inside' do
      get '/fr/notre-musique'
      expect(last_response.body).to include '<h3><a href="/fr/songs/song-number-8">Song #8</a></h3>'
      expect(last_response.body).to include 'Propulsé par'
    end

  end

  # it 'returns all the pages', pending: true do
  #   get '/all'
  #   last_response.body.should =~ /Home page/
  #   last_response.body.should =~ /<li>Home page<\/li>/
  #   last_response.body.should =~ /<li>John-doe<\/li>/
  #   last_response.body.should =~ /<li>Songs<\/li>/
  #   last_response.body.should =~ /<li>A song template<\/li>/
  # end

  # describe 'contents with_scope', pending: true do
  #   subject { get '/grunge_bands'; last_response.body }

  #   it { should match(/Layne/)}
  #   it { should_not match(/Peter/) }
  # end

  # describe 'pages with_scope', pending: true do
  #   subject { get '/unlisted_pages'; last_response.body }
  #   it { subject.should match(/Page to test the nav tag/)}
  #   it { should_not match(/About Us/)}
  # end

  # describe 'session', pending: true do

  #   subject { get '/contest'; last_response.body }

  #   it { should match(/Your code is: HELLO WORLD/) }
  #   it { should_not match(/You've already participated to that contest ! Come back later./) }

  #   describe 'assign tag' do

  #     subject { 2.times { get '/contest' }; last_response.body }

  #     it { should_not match(/Your code is: HELLO WORLD/) }
  #     it { should match(/You've already participated to that contest ! Come back later./) }

  #   end

  # end

end
