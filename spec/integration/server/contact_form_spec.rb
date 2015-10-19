require File.dirname(__FILE__) + '/../integration_helper'

describe 'ContactForm' do

  include Rack::Test::Methods

  def app
    run_server
  end

  it 'renders the form' do
    get '/contact'
    expect(last_response.body).to include '/entry_submissions/messages.json'
  end

  describe 'submit a new entry (old version)' do

    let(:url) { '/entry_submissions/messages' }
    let(:params) { {
      'entry' => { 'name' => 'John', 'email' => 'j@doe.net', 'message' => 'Bla bla' },
      'success_callback' => '/events',
      'error_callback' => '/contact' } }
    let(:response) { post_contact_form(url, params, false) }
    let(:status) { response.status }

    describe 'with json request' do

      let(:response) { post_contact_form(url, params, true) }
      let(:entry) { JSON.parse(response.body) }

      context 'unknown content type' do

        let(:url) { '/entry_submissions/foo' }

        it { expect { response }.to raise_error('Unknown content type "foo" or public_submission_enabled property not true') }

      end

      context 'when not valid' do

        let(:params) { {} }

        it 'returns an error status' do
          expect(response.status).to eq 422
        end

        describe 'errors' do

          subject { entry['errors'] }

          it 'lists all the errors' do
            expect(subject['name']).to eq ["can't be blank"]
            expect(subject['email']).to eq ["can't be blank"]
            expect(subject['email']).to eq ["can't be blank"]
          end

        end

      end

      context 'when valid' do

        it 'returns a success status' do
          expect(response.status).to eq 200
        end

      end

    end

    describe 'with html request' do

      context 'when not valid' do

        let(:params) { { 'error_callback' => '/contact' } }

        it 'returns a success status' do
          expect(response.status).to eq 200
        end

        it 'displays errors' do
          expect(response.body.to_s).to include "can't be blank"
        end

        context 'redirects outside the site' do

          let(:params) { { 'error_callback' => 'http://www.locomotivecms.com' } }

          it 'returns a success status' do
            expect(response.status).to eq 301
          end

        end

      end

      context 'when valid' do

        let(:response) { post_contact_form(url, params, false, true) }

        it 'returns a success status' do
          expect(response.status).to eq 200
        end

        it 'displays a success message' do
          expect(response.body.to_s).to include 'Thank you John'
        end

      end

    end

  end

  describe 'submit a new entry (new version)' do

    let(:url) { '/events' }
    let(:params) { {
      'content_type_slug' => 'messages',
      'entry' => { 'name' => 'John', 'email' => 'j@doe.net', 'message' => 'Bla bla' } } }
    let(:response) { post_contact_form(url, params) }
    let(:status) { response.status }

    context 'when not valid' do

      let(:params) { { 'content_type_slug' => 'messages' } }

      it 'returns a success status' do
        expect(response.status).to eq 200
      end

      it 'displays errors' do
        expect(response.body.to_s).to include "can't be blank"
      end

    end

    context 'when valid' do

      let(:response) { post_contact_form(url, params, false, true) }

      it 'returns a success status' do
        expect(response.status).to eq 200
      end

      it 'displays a success message' do
        expect(response.body.to_s).to include 'Thank you John'
      end

    end

    context 'in a different locale' do

      let(:url)       { '/fr/evenements' }
      let(:response)  { post_contact_form(url, params, false, true) }

      it 'returns a success status' do
        expect(response.status).to eq 200
      end

    end

  end

  def post_contact_form(url, params, json = false, follow_redirect = false)
    if json
      url += '.json'
      params = params.symbolize_keys
    end

    post url, params

    follow_redirect! if follow_redirect

    last_response
  end

end
