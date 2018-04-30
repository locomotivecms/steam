require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::MongoDBAdapter do

  let(:adapter) { Locomotive::Steam::MongoDBAdapter.new(database: mongodb_database, hosts: ['127.0.0.1:27017'], min_pool_size: 2, max_pool_size: 5) }

  before(:all) do
    described_class.disconnect_session
    @before_connections = current_connections
  end

  describe '#session' do

    subject { adapter.send(:session) }

    it { is_expected.not_to eq nil }

    it "don't create more Mongo sessions than the max pool" do
      10.times { subject['locomotive_sites'].find.count }
      _after = current_connections
      expect(_after).to be >= (@before_connections + 2) # min_pool_size
      expect(_after).to be <= (@before_connections + 5) # max_pool_size
    end

  end

  describe '.disconnect_session' do

    let(:connection) { adapter.send(:session) }

    subject { described_class.disconnect_session }

    it { is_expected.to eq nil }

    it 'closes clients' do
      10.times { connection['locomotive_sites'].find.count }
      subject
      expect(current_connections).to eq @before_connections
    end

  end

  def current_connections
    `mongo --eval "db.serverStatus().connections.current"`.split("\n").last.to_i
  end

end
