require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'session' do

    subject { get '/contest'; last_response.body }

    it 'displays code for the first time' do
      is_expected.to include 'Your code is: HELLO WORLD'
      is_expected.not_to include "You've already participated to that contest ! Come back later."
    end

    describe 'assign tag' do

      subject { 2.times { get '/contest' }; last_response.body }

      it 'does not display code if second time' do
        is_expected.not_to include 'Your code is: HELLO WORLD'
        is_expected.to include "You've already participated to that contest ! Come back later."
      end

    end

  end

end
