require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'nav' do

    subject { get '/all'; last_response.body }

    it 'generates the right nav' do
      is_expected.not_to include('<nav id="nav">')
      is_expected.to include('<li id="about-us-link" class="link first"><a href="/about-us">About Us</a></li>')
      is_expected.to include('<li id="music-link" class="link"><a href="/music">Music</a></li>')
      is_expected.to include('<li id="store-link" class="link"><a href="/store">Store</a></li>')
      is_expected.to include('<li id="contact-link" class="link last"><a href="/contact">Contact Us</a></li>')
      is_expected.not_to include('<li id="events-link" class="link"><a href="/events">Events</a></li>')
    end

    it 'lists all the pages' do
      is_expected.to include('Home page')
      is_expected.not_to include('<li>Page not found</li>')
      is_expected.to include('<li>Home page</li>')
      is_expected.to include('<li>John doe</li>')
      is_expected.to include('<li>A song template</li>')
    end

    it 'lists all the pages from the site liquid drop' do
      is_expected.to include('<!-- TEST -->About Us - Music - Store - Contact Us - Events - Basic page - A sample contest - Various uses of the with_scope tag - Grunge leaders - Tags - Unlisted pages - Archives - All the pages - Layouts - Songs<!-- TEST -->')
    end

    describe 'with wrapper' do

      subject { get '/tags/nav'; last_response.body }

      it { is_expected.to include('<nav id="nav">') }

    end

    describe 'with snippet to render the label' do

      subject { get '/tags/nav'; last_response.body }

      it { is_expected.to include('<li id="store-link" class="link"><a href="/store">-Store-</a></li>') }

    end

    describe 'very deep' do

      subject { get '/tags/nav-in-deep'; last_response.body }

      it { is_expected.to include('<li id="john-doe-link" class="link first last">') }

    end

  end
end
