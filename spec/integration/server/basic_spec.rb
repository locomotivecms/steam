require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'displays an error message if the site does not exist' do
    get '/index', {},{ 'HTTP_HOST' => 'www.nowhere.org/index' }
    expect(last_response.status).to eq(404)
    expect(last_response.body).to eq 'Hi, we are sorry but no site was found.'
  end

  it 'shows the index page' do
    get '/index'
    expect(last_response.status).to eq(200)
    expect(last_response.body).to match(/Upcoming events/)
  end

  it 'shows the about us page' do
    get '/about-us'
    expect(last_response.status).to eq(200)
  end

  it 'shows an inner page' do
    get '/about-us/jane-doe'
    expect(last_response.body).to include '<link href="/stylesheets/application.css"'
    expect(last_response.body).to include 'Lorem ipsum dolor sit amet'
  end

  describe 'redirection' do

    let(:url) { '/store' }

    subject { get url; last_response }

    it 'redirects to another site' do
      expect(subject.status).to eq(301)
      expect(subject.location).to eq('http://www.apple.com/en/itunes/')
    end

    context 'localized page' do

      let(:url) { '/fr/magasin' }

      it 'redirects to another site' do
        expect(subject.status).to eq(301)
        expect(subject.location).to eq('http://www.apple.com/fr/itunes/')
      end

    end

  end

  describe 'page not found' do

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

  describe 'seo trailing slash' do

    let(:url) { '/events/' }
    subject { get url; last_response }

    it 'redirects to the url without the trailing slash' do
      expect(subject.status).to eq(301)
      expect(subject.location).to eq('/events')
    end

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
      expect(last_response.body).to include 'another version'
    end

    it 'renders a page under a templatized one' do
      get '/songs/song-number-2/band'
      expect(last_response.body).to include 'Song #2'
      expect(last_response.body).to include 'Leader: Eddie'
    end

    it 'redirects to the 404 if it does not match a content entry' do
      get '/songs/unknown'
      expect(last_response).to be_redirect
      follow_redirect!
      expect(last_response.status).to eq(404)
    end

  end

  describe 'translations' do

    it 'translates strings' do
      get '/'
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

  describe 'contents with_scope' do

    subject { get '/grunge-bands'; last_response.body }

    it 'filters content entries' do
      is_expected.to include 'Layne'
      is_expected.not_to include 'Peter'
    end

  end

  describe 'pages with_scope' do

    subject { get '/unlisted-pages'; last_response.body }

    it { is_expected.to include 'Page to test the nav tag' }
    it { is_expected.not_to include 'About Us' }

  end

end
