require 'spec_helper'

describe Locomotive::Steam::Section do

  let(:attributes)  { {} }
  let(:section)     { described_class.new(attributes) }

  describe '#source' do

    let(:attributes) { { template:  "Hello world"} }

    subject { section.source }
    it { is_expected.to eq 'Hello world' }

  end

  describe '#definition' do
    let(:attributes) { { definition: { name: 'aName' } } }
    subject { section.definition }
    it { is_expected.to eq({ 'name' => 'aName' }) }
  end

end
