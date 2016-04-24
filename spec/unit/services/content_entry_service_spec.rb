require 'spec_helper'

describe Locomotive::Steam::ContentEntryService do

  let(:site)              { instance_double('Site', default_locale: 'en') }
  let(:locale)            { 'en' }
  let(:type_repository)   { instance_double('ContentTypeRepository') }
  let(:entry_repository)  { instance_double('Repository', site: site, locale: locale, content_type_repository: type_repository) }
  let(:service)           { described_class.new(type_repository, entry_repository, locale) }

  before { allow(entry_repository).to receive(:with).and_return(entry_repository) }

  describe '#validate' do

    let(:attributes)        { { title: 'Hello world' } }
    let(:unique_fields)     { {} }
    let(:first_validation)  { false }
    let(:errors)            { [:title] }
    let(:type)              { instance_double('Comments') }
    let(:entry)             { instance_double('Entry', title: 'Hello world', content_type: type, valid?: first_validation, errors: errors, attributes: { title: 'Hello world' }, localized_attributes: []) }

    before do
      allow(type_repository).to receive(:by_slug).and_return(type)
      allow(type_repository).to receive(:look_for_unique_fields).and_return(unique_fields)
      allow(entry_repository).to receive(:build).with(attributes).and_return(entry)
    end

    subject { service.send(:validate, entry_repository, entry) }

    context 'valid' do

      let(:first_validation) { true }
      let(:errors) { {} }

      it { is_expected.to eq true }
      it { subject; expect(entry.errors.empty?).to eq true }

    end

    context 'not valid' do

      it { is_expected.to eq false }
      it { subject; expect(entry.errors).to eq([:title]) }

      context 'with unique fields' do

        let(:unique_fields) { { title: instance_double('Field', name: 'title') } }

        before do
          allow(entry_repository).to receive(:exists?).with(title: 'Hello world').and_return(true)
          expect(entry.errors).to receive(:add).with(:title, :unique).and_return(true)
        end

        it { is_expected.to eq false }
        it { subject; expect(entry.errors).to eq([:title]) }

      end

    end

  end

end
