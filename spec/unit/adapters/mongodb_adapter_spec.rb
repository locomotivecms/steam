require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::MongoDBAdapter do

  let(:adapter) { described_class.new(nil) }

  describe '#key' do

    subject { adapter.key(:title, :in) }

    it { is_expected.to eq :title.in }

  end

  describe '#make_id' do

    let(:id) { '56fd9f48a2f42217744a85d7' }

    subject { adapter.make_id(id) }

    it { is_expected.to eq(BSON::ObjectId.from_string('56fd9f48a2f42217744a85d7')) }

    context 'passing a BSON::ObjectId' do

      let(:id) { BSON::ObjectId.from_string('56fd9f48a2f42217744a85d7') }

      it { is_expected.to eq(BSON::ObjectId.from_string('56fd9f48a2f42217744a85d7')) }

    end

  end

end
