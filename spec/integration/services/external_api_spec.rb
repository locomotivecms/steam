require 'spec_helper'

describe Locomotive::Steam::Services::ExternalAPI do

  pending 'API rate limit exceeded'

  let(:service) { Locomotive::Steam::Services::ExternalAPI.new }

  describe '#consume' do

    let(:url)     { 'https://api.github.com/users/did/repos' }
    let(:options) { { format: "'json'", with_user_agent: true } }

    subject { service.consume(url, options) }

    it { expect(subject.size).to_not eq 0 }

  end

end
