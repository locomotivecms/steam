require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::Site do

  let(:loader)      { instance_double('Loader', attributes: { name: 'Acme' }) }
  let(:repository)  { Locomotive::Steam::Repositories::Filesystem::Site.new(loader) }

  describe '#by_host' do

    subject { repository.by_host(nil, {}) }

    it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::Site }
    it { expect(subject.name).to eq 'Acme' }

  end

end
