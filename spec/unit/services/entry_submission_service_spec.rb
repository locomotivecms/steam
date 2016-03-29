require 'spec_helper'

describe Locomotive::Steam::EntrySubmissionService do

  let(:entry_service) { instance_double('ContentEntryService') }
  let(:service)       { described_class.new(entry_service) }

  describe '#find' do

    subject { service.find('messages', '42') }

    it { expect(entry_service).to receive(:find).with('messages', '42'); subject }

  end

  describe '#submit' do

    let(:content_type) { instance_double('ContentType', public_submission_enabled: public_submission_enabled) }

    before { allow(entry_service).to receive(:get_type).with('messages').and_return(content_type) }

    subject { service.submit('messages', { name: 'John Doe', body: 'Lorem ipsum' }) }

    context "the content type doesn't exist" do

      let(:public_submission_enabled) { true }
      let(:content_type) { nil }
      it { is_expected.to eq nil }

    end

    context "the content type exists but it's not enabled for public submission" do

      let(:public_submission_enabled) { false }
      it { is_expected.to eq nil }

    end

    context 'the content type exists and is enabled for public submission' do

      let(:public_submission_enabled) { true }
      it 'calls the entry service to create the message' do
        expect(entry_service).to receive(:create).with(content_type, { name: 'John Doe', body: 'Lorem ipsum' })
        subject
      end

    end

  end

  describe '#to_json' do

    let(:entry) { instance_double('Entry', to_json: "{'name':'John'}") }

    subject { service.to_json(entry) }

    it { is_expected.to eq("{'name':'John'}") }

    context 'entry is nil' do

      let(:entry) { nil }
      it { is_expected.to eq nil }

    end

  end

end

  # let(:site)              { instance_double('Site', default_locale: 'en') }
  # let(:locale)            { 'en' }
  # let(:type_repository)   { instance_double('ContentTypeRepository') }
  # let(:entry_repository)  { instance_double('Repository', site: site, locale: locale, content_type_repository: type_repository) }
  # let(:service)           { described_class.new(type_repository, entry_repository, locale) }

  # before { allow(entry_repository).to receive(:with).and_return(entry_repository) }

  # describe '#find' do

  #   let(:type_slug) { 'articles' }
  #   let(:slug)      { 'hello-world' }
  #   subject { service.find(type_slug, slug) }

  #   context 'unknown content type' do

  #     before { allow(type_repository).to receive(:by_slug).and_return(nil) }
  #     it { is_expected.to eq nil }

  #   end

  #   context 'existing content type' do

  #     let(:type) { instance_double('Articles') }
  #     let(:entry) { instance_double('Entry', title: 'Hello world', content_type: type, attributes: { title: 'Hello world' }, localized_attributes: []) }

  #     before do
  #       allow(type_repository).to receive(:by_slug).and_return(type)
  #       allow(entry_repository).to receive(:by_slug).with('hello-world').and_return(entry)
  #     end

  #     it { is_expected.to eq entry }

  #   end

  # end

  # describe '#to_json' do

  #   let(:entry) { nil }
  #   subject { service.to_json(entry) }

  #   it { is_expected.to eq nil }

  #   context 'existing content entry' do

  #     let(:field)   { instance_double('TitleField', name: :title, type: :string) }
  #     let(:fields)  { [field] }
  #     let(:type)    { instance_double('Articles', slug: 'articles', label_field_name: :title, fields_by_name: { title: field }, persisted_field_names: [:title]) }
  #     let(:entry)   { Locomotive::Steam::ContentEntry.new(_slug: 'hello-world', title: 'Hello world', content_type: type) }

  #     before { allow(type).to receive(:fields).and_return(instance_double('FieldRepository', all: fields)) }

  #     it { is_expected.to match %r{{"_id":null,"_slug":"hello-world","_label":"Hello world","_visible":true,"_position":0,"content_type_slug":"articles","created_at":"[^\"]+","updated_at":"[^\"]+","title":"Hello world"}} }

  #     context 'with errors' do

  #       before { entry.errors.add(:title, "can't be blank") }

  #       it { is_expected.to match %r{,\"errors\":\{\"title\":\[\"can't be blank\"\]\}} }

  #     end

  #   end

  # end

  # describe '#submit' do

  #   let(:slug)        { nil }
  #   let(:attributes)  { { title: 'Hello world' } }
  #   subject { service.submit(slug, attributes) }

  #   it { is_expected.to eq nil }

  #   context 'unknown content type' do

  #     let(:slug) { 'articles' }

  #     before { allow(type_repository).to receive(:by_slug).with('articles').and_return nil }

  #     it { is_expected.to eq nil }

  #   end

  #   context 'existing content type' do

  #     let(:unique_fields)     { {} }
  #     let(:first_validation)  { false }
  #     let(:errors)            { [:title] }
  #     let(:enabled)           { true }
  #     let(:type)  { instance_double('Comments', public_submission_enabled: enabled) }
  #     let(:entry) { instance_double('Entry', title: 'Hello world', content_type: type, valid?: first_validation, errors: errors, attributes: { title: 'Hello world' }, localized_attributes: []) }
  #     let(:slug)  { 'comments' }

  #     before do
  #       allow(type_repository).to receive(:by_slug).and_return(type)
  #       allow(type_repository).to receive(:look_for_unique_fields).and_return(unique_fields)
  #       allow(entry_repository).to receive(:build).with(attributes).and_return(entry)
  #     end

  #     context 'public submission disabled' do

  #       let(:enabled) { false }
  #       it { is_expected.to eq nil }

  #     end

  #     context 'valid' do

  #       before { expect(entry_repository).to receive(:create) }

  #       let(:first_validation) { true }
  #       let(:errors) { {} }

  #       it { is_expected.to eq entry }
  #       it { expect(subject.errors.empty?).to eq true }

  #     end

  #     context 'not valid' do

  #       before { expect(entry_repository).not_to receive(:create) }

  #       it { is_expected.to eq entry }
  #       it { expect(subject.errors).to eq([:title]) }

  #       context 'with unique fields' do

  #         let(:unique_fields) { { title: instance_double('Field', name: 'title') } }

  #         before do
  #           allow(entry_repository).to receive(:exists?).with(title: 'Hello world').and_return(true)
  #           expect(entry.errors).to receive(:add).with(:title, :unique).and_return(true)
  #         end

  #         it { is_expected.to eq entry }
  #         it { expect(subject.errors).to eq([:title]) }

  #       end

  #     end

  #   end

  # end

# end
