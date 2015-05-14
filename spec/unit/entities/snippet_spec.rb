require 'spec_helper'

describe Locomotive::Steam::Snippet do

  let(:attributes)  { {} }
  let(:snippet)     { described_class.new(attributes) }

  describe '#source' do

    let(:attributes) { { template: 'Hello world' } }

    subject { snippet.source }
    it { is_expected.to eq 'Hello world' }

  end

end
