require 'spec_helper'

describe Locomotive::Steam::ExternalAPIService do

  pending 'API rate limit exceeded'

  if ENV['TRAVIS'].blank?

    let(:service) { described_class.new }

    describe '#consume' do

      let(:url)     { 'https://api.github.com/users/did/repos' }
      let(:options) { { format: "'json'", with_user_agent: true } }

      subject { service.consume(url, options) }

      it { expect(subject.size).to_not eq 0 }

      context 'returns the status too' do

        subject { service.consume(url, options, true) }

        it { expect(subject[:status]).to eq 200 }
        it { expect(subject[:data].size).to_not eq 0 }

      end

    end

  else

    pending 'API not available in Travis'

  end

end
