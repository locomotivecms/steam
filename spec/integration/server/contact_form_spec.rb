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

  describe '#submit' do

    let(:params) { {
      'entry' => { 'name' => 'John', 'email' => 'j@doe.net', 'message' => 'Bla bla' },
      'success_callback' => '/events',
      'error_callback' => '/contact' } }
    let(:response) { post_contact_form(params, false) }
    let(:status) { response.status }

    describe 'with json request' do

      let(:response) { post_contact_form(params, true) }
      let(:entry) { JSON.parse(response.body) }

      context 'when not valid' do

        let(:params) { {} }

        it 'returns an error status' do
          expect(response.status).to eq 422
        end

        describe 'errors' do

          subject { entry['errors'] }

          it 'lists all the errors' do
            expect(subject['name']).to eq ["can't not be blank"]
            expect(subject['email']).to eq ["can't not be blank"]
            expect(subject['email']).to eq ["can't not be blank"]
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
          expect(response.body.to_s).to include "can't not be blank"
        end

      end

      context 'when valid' do

        let(:response) { post_contact_form(params, false, true) }

        it 'returns a success status' do
          expect(response.status).to eq 200
        end

        it 'displays a success message' do
          expect(response.body.to_s).to include 'Thank you John'
        end

      end

    end

  end

  def post_contact_form(params, json = false, follow_redirect = false)
    url = '/entry_submissions/messages'
    url += '.json' if json
    params = params.symbolize_keys if json
    post url, params
    if follow_redirect
      follow_redirect!
    end
    last_response
  end

end
