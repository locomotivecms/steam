require 'spec_helper'

describe Locomotive::Steam::RecaptchaService do

  let(:api_url)     { nil }
  let(:secret)      { 'asecretkey' }
  let(:min_score)   { nil }
  let(:site)        { instance_double('Site', metafields: { google: { recaptcha_api_url: api_url, 'recaptcha_secret' => secret, recaptcha_min_score: min_score } }) }
  let(:request)     { instance_double('Request', ip: '127.0.0.1') }
  let(:service)     { described_class.new(site, request) }

  describe '#verify' do

    let(:code) { nil }

    subject { service.verify(code) }

    it { is_expected.to eq false }

    context 'the code is not nil' do

      let(:code)    { '42' }
      let(:success) { false }
      let(:body)    { { 'success' => success } }

      before do
        expect(HTTParty).to receive(:get).with('https://www.google.com/recaptcha/api/siteverify', {
          query: {
            secret:   'asecretkey',
            response: '42',
            remoteip: '127.0.0.1'
          }
        }).and_return(instance_double('Response', parsed_response: body))
      end

      context 'the code is verified' do

        let(:success) { true }
        it { is_expected.to eq true }

      end

      context 'the code is not verified' do

        let(:success) { false }
        it { is_expected.to eq false }

      end

      context 'the response includes a score (reCAPTCHA v3)' do

        let(:success) { true }
        let(:body)    { { 'success' => success, 'score' => score } }
        let(:score)   { 0.9 }

        it { is_expected.to eq true }

        context 'the score is below the default minimum' do

          let(:score) { 0.1 }
          it { is_expected.to eq false }

        end

        context 'the score equals the default minimum' do

          let(:score) { 0.2 }
          it { is_expected.to eq true }

        end

        context 'the code is not verified' do

          let(:success) { false }
          it { is_expected.to eq false }

        end

        context 'the site defines its own minimum score' do

          let(:min_score) { '0.5' }

          context 'the score is below it' do

            let(:score) { 0.4 }
            it { is_expected.to eq false }

          end

          context 'the score is above it' do

            let(:score) { 0.6 }
            it { is_expected.to eq true }

          end

        end

        context 'the site defines a blank minimum score' do

          let(:min_score) { '' }
          let(:score)     { 0.1 }

          it { is_expected.to eq false }

        end

      end

    end

    context 'using a different API url' do

      let(:code)    { '42' }
      let(:api_url) { 'https://recaptcha.net/api' }

      before do
        expect(HTTParty).to receive(:get).with('https://recaptcha.net/api', {
          query: {
            secret:   'asecretkey',
            response: '42',
            remoteip: '127.0.0.1'
          }
        }).and_return(instance_double('Response', parsed_response: { 'success' => true }))
      end

      it { is_expected.to eq true }

    end

  end

end
