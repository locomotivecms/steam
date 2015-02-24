require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::MongoDBAdapter do

  let(:adapter) { described_class.new(nil) }

  describe '#key' do

    subject { adapter.key(:title, :in) }

    it { is_expected.to eq :title.in }

  end

end
