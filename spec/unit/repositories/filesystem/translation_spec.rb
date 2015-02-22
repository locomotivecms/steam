# require 'spec_helper'

# describe Locomotive::Steam::Repositories::Filesystem::Translation do

#   let(:loader)  { instance_double('Loader', list_of_attributes: [{ key: 'powered_by', values: { 'en' => 'Powered by Steam', 'fr' => 'Propulsé par Steam' } }]) }
#   let(:locale)  { :en }

#   let(:repository) { Locomotive::Steam::Repositories::Filesystem::Translation.new(loader) }

#   describe '#collection' do

#     subject { repository.send(:collection).first }

#     it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::Translation }
#     it { expect(subject.key).to eq 'powered_by' }

#   end

#   describe '#find' do

#     let(:key) { nil }
#     subject { repository.find(key) }

#     it { is_expected.to eq nil }

#     context 'existing translation' do

#       let(:key) { 'powered_by' }
#       it { expect(subject.values).to eq({ 'en' => 'Powered by Steam', 'fr' => 'Propulsé par Steam' }) }

#     end

#   end

# end
