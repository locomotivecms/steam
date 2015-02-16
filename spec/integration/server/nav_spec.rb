require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'nav' do

    subject { get '/all'; last_response.body }

    it { is_expected.not_to include('<nav id="nav">') }

    it { is_expected.to include('<li id="about-us-link" class="link first"><a href="/about-us">About Us</a></li>') }

    it { is_expected.to include('<li id="music-link" class="link"><a href="/music">Music</a></li>') }

    it { is_expected.to include('<li id="store-link" class="link"><a href="/store">Store</a></li>') }

    it { is_expected.to include('<li id="contact-link" class="link last"><a href="/contact">Contact Us</a></li>') }

    it { is_expected.not_to include('<li id="events-link" class="link"><a href="/events">Events</a></li>') }

    describe 'with wrapper' do

      subject { get '/tags/nav'; last_response.body }

      it { is_expected.to include('<nav id="nav">') }

    end

    describe 'very deep' do

      subject { get '/tags/nav-in-deep'; last_response.body }

      it { is_expected.to include('<li id="john-doe-link" class="link first last">') }

    end

  end
end
