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

  # it 'shows a content type template', pending: true do
  #   get '/songs/song-number-1'
  #   last_response.body.should =~ /Song #1/
  # end

  # it 'renders a page under a templatized one', pending: true do
  #   get '/songs/song-number-1/band'
  #   last_response.body.should =~ /Song #1/
  #   last_response.body.should =~ /Leader: Eddie/
  # end

  it 'translates strings' do
    get '/en'
    expect(last_response.body).to include 'Powered by'
    get '/fr'
    expect(last_response.body).to include 'Propulsé par'
  end

  # it 'provides translation in scopes', pending: true do
  #   get '/'
  #   last_response.body.should =~ /scoped_translation=.French./
  # end

  # it 'translates a page with link_to tags inside', pending: true do
  #   get '/fr/notre-musique'
  #   last_response.body.should =~ /<h3><a href="\/fr\/songs\/song-number-8">Song #8<\/a><\/h3>/
  #   last_response.body.should =~ /Propulsé par/
  # end

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

  # describe 'theme assets', pending: true do

  #   subject { get '/all'; last_response.body }

  #   it { should match(/<link href="\/stylesheets\/application.css" media="screen" rel="stylesheet" type="text\/css" \/>/) }

  #   it { should match(/<script src="\/javascripts\/application.js" type='text\/javascript'><\/script>/) }

  #   it { should match(/<link rel="alternate" type="application\/atom\+xml" title="A title" href="\/foo\/bar" \/>/) }

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
