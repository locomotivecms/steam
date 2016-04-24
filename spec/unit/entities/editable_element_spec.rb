require 'spec_helper'

describe Locomotive::Steam::EditableElement do

  let(:attributes) { {} }
  let(:page) { described_class.new(attributes) }

  it { expect(page.block).to eq nil }

  describe '#source' do

    let(:source)      { 'Hello world' }
    let(:attributes)  { { content: 'Lorem ipsum', source: source } }

    subject { page.source }

    it { is_expected.to eq 'Hello world' }

    context 'no source attribute' do

      let(:source) { nil }

      it { is_expected.to eq 'Lorem ipsum' }

    end

  end

end
