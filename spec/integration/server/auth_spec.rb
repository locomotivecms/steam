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

  describe 'forgot password action' do

    let(:email) { '' }

    let(:params) { {
      auth_action:                'forgot_password',
      auth_content_type:          'accounts',
      auth_id_field:              'email',
      auth_id:                    email,
      auth_reset_password_url:    'http://acme.com/account/reset-password',
      auth_callback:              '/account/sign-in',
      auth_email_from:            'support@acme.com',
      auth_email_handle:          'reset_password_instructions',
      auth_email_smtp_address:    'smtp.nowhere.net',
      auth_email_smtp_user_name:  'jane',
      auth_email_smtp_password:   'easyone'
    } }

    it 'renders the forgot password page with an error message' do
      forgot_password
      expect(last_response.status).to eq 200
      expect(last_response.body).to include 'Forgot your password'
      expect(last_response.body).to include 'Your email is unknown'
    end

    context 'with an known email' do

      let(:email) { 'john@doe.net' }

      it 'sends an email to the account' do
        forgot_password
        expect(last_response.status).to eq 200
        expect(last_response.body).to include "The instructions for changing your password have been emailed to you"
      end

    end

    def forgot_password(follow_redirect = false)
      post '/account/forgot-password', params
      follow_redirect! if follow_redirect
      last_response
    end

  end

end


