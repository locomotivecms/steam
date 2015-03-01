require 'spec_helper'

describe Locomotive::Steam::ContentTypeField do

  let(:content_type) { described_class.new(name: 'title', type: 'string') }

  describe '#type' do

    subject { content_type.type }
    it { is_expected.to eq :string }

  end

end
