require File.dirname(__FILE__) + '/../integration_helper'

describe 'Authentication' do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'sign in action' do

    it 'renders the form' do
      get '/account/sign-in'
      expect(last_response.body).to include '/account/sign-in'
      expect(last_response.body).not_to include "You've been signed out"
    end

    describe 'press the sign in button' do

      let(:params) { {
        auth_action:          'sign_in',
        auth_content_type:    'accounts',
        auth_id_field:        'email',
        auth_password_field:  'password',
        auth_id:              'john@doe.net',
        auth_password:        'easyone',
        auth_callback:        '/account/me'
      } }

      it 'redirects to the callback' do
        sign_in(params)
        expect(last_response.status).to eq 301
        expect(last_response.location).to eq '/account/me'
      end

      it 'displays the profile page as described in the params' do
        sign_in(params, true)
        expect(last_response.body).to include "My name is John and I'm logged in!"
      end

      context 'wrong credentials' do

        let(:params) { {
          auth_action:          'sign_in',
          auth_content_type:    'accounts',
          auth_id_field:        'email',
          auth_password_field:  'password',
          auth_id:              'john@doe.net',
          auth_password:        'dontrememberit',
          auth_callback:        '/account/me'
        } }

        it 'renders the sign in page with an error message' do
          sign_in(params)
          expect(last_response.status).to eq 200
          expect(last_response.body).to include '/account/sign-in'
          expect(last_response.body).to include 'Your email and/or password are incorrect'
        end

      end

      def sign_in(params, follow_redirect = false)
        post '/account/sign-in', params
        follow_redirect! if follow_redirect
        last_response
      end

    end

  end

  describe 'sign out action' do

    let(:params) { {
      auth_action:          'sign_out',
      auth_content_type:    'accounts'
    } }

    let(:rack_session) { {
      'authenticated_entry_type'  => 'accounts',
      'authenticated_entry_id'    => 'john'
    } }

    it 'displays the profile page as described in the params' do
      post '/account/sign-in', params, { 'rack.session' => rack_session }
      expect(last_response.body).to include "You've been signed out"
      expect(last_response.body).not_to include "You're already authenticated!"
    end

  end

end


