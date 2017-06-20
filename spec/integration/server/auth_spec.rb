require File.dirname(__FILE__) + '/../integration_helper'

describe 'Authentication' do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'sign up action' do

    it 'renders the form' do
      get '/account/sign-up'
      expect(last_response.body).to include '/account/sign-up'
    end

    describe 'press the sign up button' do

      let(:params) { {
        auth_action:          'sign_up',
        auth_content_type:    'accounts',
        auth_id_field:        'email',
        auth_password_field:  'password',
        auth_callback:        '/account/me',
        auth_entry: {
          name:                   'Chris Cornell',
          email:                  'chris@soundgarden.band',
          password:               'easyone',
          password_confirmation:  'easyone'
        }
      } }

      it 'redirects to the callback' do
        sign_up(params)
        expect(last_response.status).to eq 301
        expect(last_response.location).to eq '/account/me'
      end

      it 'displays the profile page as described in the params' do
        params[:auth_entry][:email] = 'chris.cornell@soundgarden.band'
        sign_up(params, true)
        expect(last_response.body).to include "My name is Chris Cornell and I'm logged in!"
      end

      context 'wrong parameters' do

        let(:params) { {
          auth_action:          'sign_up',
          auth_content_type:    'accounts',
          auth_id_field:        'email',
          auth_password_field:  'password',
          auth_callback:        '/account/me',
          auth_entry: {
            name:                   'Chris Cornell',
            email:                  'chris@soundgarden.band',
            password:               'easyone',
            password_confirmation:  'easyone2'
          }
        } }

        it 'renders the sign up page with an error message' do
          sign_up(params)
          expect(last_response.status).to eq 200
          expect(last_response.body).to include '/account/sign-up'
          expect(last_response.body).to include "doesn't match password"
        end

      end

      def sign_up(params, follow_redirect = false)
        post '/account/sign-up', params
        follow_redirect! if follow_redirect
        last_response
      end

    end

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
      post '/account/forgot-password', params
      expect(last_response.status).to eq 200
      expect(last_response.body).to include 'Forgot your password'
      expect(last_response.body).to include 'Your email is unknown'
    end

    context 'with an known email' do

      let(:email) { 'john@doe.net' }

      it 'sends an email to the account' do
        post '/account/forgot-password', params
        expect(last_response.status).to eq 200
        expect(last_response.body).to include "The instructions for changing your password have been emailed to you"
      end

    end

  end

  describe 'reset password action' do

    let(:token) { '' }
    let(:new_password) { 'newone!' }

    let(:params) { {
      auth_action:                'reset_password',
      auth_content_type:          'accounts',
      auth_password_field:        'password',
      auth_password:              new_password,
      auth_reset_token:           token,
      auth_callback:              '/account/me'
    } }

    it 'renders the reset password page with an error message' do
      post '/account/reset-password', params
      expect(last_response.status).to eq 200
      expect(last_response.body).to include 'Change your password'
      expect(last_response.body).to include 'The reset token is not valid anymore'
    end

    context 'with an expired token' do

      let(:token) { '420000000000001' }

      it 'renders the reset password page with an error message' do
        post '/account/reset-password', params
        expect(last_response.status).to eq 200
        expect(last_response.body).to include 'Change your password'
        expect(last_response.body).to include 'The reset token is not valid anymore'
      end

    end

    context 'with a valid token' do

      let(:token) { '420000000000000' }

      it 'sends an email to the account' do
        post '/account/reset-password', params
        expect(last_response.status).to eq 301
        follow_redirect!
        expect(last_response.body).to include "My name is Jane and I'm logged in!"
      end

      context 'with a too short password' do

        let(:new_password) { 'short' }

        it 'renders the reset password page with an error message' do
          post '/account/reset-password', params
          expect(last_response.status).to eq 200
          expect(last_response.body).to include 'Change your password'
          expect(last_response.body).to include 'Your password is too short'
        end

      end

    end

  end

end


