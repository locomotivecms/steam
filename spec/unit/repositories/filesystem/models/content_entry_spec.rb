require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::Models::ContentEntry do

  let(:type)        { instance_double('ContentType', slug: 'articles', label_field_name: :title, localized_fields_names: [:title], fields_by_name: {}) }
  let(:attributes)  { { title: 'Hello world', _slug: 'hello-world' } }
  let(:content_entry)  do
    Locomotive::Steam::Repositories::Filesystem::Models::ContentEntry.new(attributes).tap do |entry|
      entry.content_type = type
    end
  end

  describe '#_label' do

    subject { content_entry._label }
    it { is_expected.to eq 'Hello world' }

  end

  describe '#_id' do

    subject { content_entry._id }
    it { is_expected.to eq 'hello-world' }

  end

  describe '#content_type_slug' do

    subject { content_entry.content_type_slug }
    it { is_expected.to eq 'articles' }

  end

  describe '#localized_attributes' do

    subject { content_entry.localized_attributes }
    it { is_expected.to include :seo_title }
    it { is_expected.to include :title }
    it { is_expected.to include :_slug }

  end

  describe 'dynamic attributes' do

    let(:field_type)  { :string }
    let(:attributes)  { { my_field: value } }
    let(:field)       { instance_double('Field', name: :my_field, type: field_type) }
    before { allow(type).to receive(:fields_by_name).and_return(my_field: field) }

    subject { content_entry.my_field }

    describe 'unable to cast it' do

      let(:field_type)  { :float }
      let(:value)       { [] }
      it { is_expected.to eq nil }

    end

    context 'a string' do
      let(:value) { 'Hello world' }
      it { is_expected.to eq 'Hello world' }
      context 'localized' do
        let(:value) { { en: 'Hello world', fr: 'Bonjour monde' } }
        it { is_expected.to eq({ en: 'Hello world', fr: 'Bonjour monde' }) }
      end
    end

    context 'an integer' do
      let(:field_type)  { :integer }
      let(:value)       { '42' }
      it { is_expected.to eq 42 }
      context 'localized' do
        let(:value) { { en: 42, fr: '42' } }
        it { is_expected.to eq({ en: 42, fr: 42 }) }
      end
    end

    context 'a float' do
      let(:field_type)  { :float }
      let(:value)       { '42.0' }
      it { is_expected.to eq 42.0 }
      context 'localized' do
        let(:value) { { en: 42.0, fr: '42.0' } }
        it { is_expected.to eq({ en: 42.0, fr: 42.0 }) }
      end
    end

    context 'a date' do
      let(:field_type)  { :date }
      let(:value)       { '2007/06/29' }
      let(:date)        { Date.parse('2007/06/29') }
      it { is_expected.to eq date }
      context 'localized' do
        let(:value) { { en: '2007/06/29', fr: date } }
        it { is_expected.to eq({ en: date, fr: date }) }
      end
    end

    context 'a date time' do
      let(:field_type)  { :date_time }
      let(:value)       { '2007/06/29 00:00:00' }
      let(:datetime)    { DateTime.parse('2007/06/29 00:00:00') }
      it { is_expected.to eq datetime }
      context 'localized' do
        let(:value) { { en: '2007/06/29 00:00:00', fr: datetime } }
        it { is_expected.to eq({ en: datetime, fr: datetime }) }
      end
    end

    context 'a file' do
      let(:field_type)  { :file }
      let(:value)       { 'foo.png' }
      it { is_expected.to eq({ 'url' => 'foo.png' }) }
      context 'localized' do
        let(:value) { { en: 'foo-en.png', fr: 'foo-fr.png' } }
        it { is_expected.to eq({ en: { 'url' => 'foo-en.png' }, fr: { 'url' => 'foo-fr.png' } }) }
      end
    end

    context 'a belongs_to relationship' do
      let(:field_type)  { :belongs_to }
      let(:value)       { 'john-doe' }
      it { expect(subject.type).to eq :belongs_to }
      it { expect(subject.target_slugs).to eq ['john-doe'] }
      it { expect(subject.source).to eq content_entry }
      it { expect(subject.field).to eq field }
    end

    context 'a has_many relationship' do
      let(:field_type)  { :has_many }
      let(:value)       { nil }
      it { expect(subject.type).to eq :has_many }
      it { expect(subject.target_slugs).to eq [] }
      it { expect(subject.source).to eq content_entry }
      it { expect(subject.field).to eq field }
    end

    context 'a many_to_many relationship' do
      let(:field_type)  { :many_to_many }
      let(:value)       { ['john-doe', 'jane-doe'] }
      it { expect(subject.type).to eq :many_to_many }
      it { expect(subject.target_slugs).to eq ['john-doe', 'jane-doe'] }
      it { expect(subject.source).to eq content_entry }
      it { expect(subject.field).to eq field }
    end

  end

end
