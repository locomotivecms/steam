require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::Models::ContentType do

  let(:fields)        { [instance_double('Field1', label: 'Title', name: 'title'), instance_double('Field2', label: 'Author', name: 'author')] }
  let(:content_type)  do
    Locomotive::Steam::Repositories::Filesystem::Models::ContentType.new(name: 'Articles').tap do |type|
      type.fields = fields
    end
  end

  describe '#field_by_name' do

    let(:name) { nil }
    subject { content_type.field_by_name(name) }

    it { is_expected.to eq nil }

    context 'not nil name' do

      let(:name) { 'author' }
      it { expect(subject.label).to eq 'Author' }

    end

  end

  describe '#label_field' do

    subject { content_type.label_field.try(:label) }
    it { is_expected.to eq 'Title' }

    context 'defined within the content type itself' do

      before { allow(content_type.attributes).to receive(:[]).with(:label_field_name).and_return('author') }
      it { is_expected.to eq 'Author' }

    end

  end

end
