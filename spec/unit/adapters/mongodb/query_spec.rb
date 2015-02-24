require 'spec_helper'

require 'origin'

require_relative '../../../../lib/locomotive/steam/adapters/mongodb/origin.rb'
require_relative '../../../../lib/locomotive/steam/adapters/mongodb/query.rb'

# require_relative '../../../../lib/locomotive/steam/adapters/memory/order.rb'
# require_relative '../../../../lib/locomotive/steam/adapters/memory/query.rb'

describe Locomotive::Steam::Adapters::MongoDB::Query do

  let(:site)  { instance_double('Site', _id: 42) }
  let(:scope) { instance_double('Scope', locale: :en, site: site) }
  let(:localized_attributes) { [:title] }
  let(:block) { nil }

  let(:query) { Locomotive::Steam::Adapters::MongoDB::Query.new(scope, localized_attributes, &block) }

  describe '#where' do

    let(:criterion) { { fullpath: 'index' } }

    context 'simple call' do

      before { query.where(criterion) }

      it { expect(query.criteria).to eq({ site_id: 42, fullpath: 'index' }) }

    end

    context 'chained' do

      let(:another_criterion) { { published: true } }

      before { query.where(criterion).where(another_criterion) }

      it { expect(query.criteria).to eq({ site_id: 42, fullpath: 'index', published: true }) }

    end

  end

  describe '#order_by' do

    it { expect(query.order_by(title: :asc, published: :desc).sort).to eq [{title: :asc, published: :desc}] }

  end

  describe 'chaining where and order_by' do

    before { query.where(published: true).order_by(title: :asc) }

    it { expect(query.criteria).to eq({ site_id: 42, published: true }) }
    it { expect(query.sort).to eq([{ title: :asc }]) }

  end

  describe '#to_origin' do

    before { query.where(title: 'index').order_by(title: :asc) }

    subject { query.to_origin }

    it { expect(subject.selector).to eq({ 'site_id' => 42, 'title.en' => 'index' }) }
    it { expect(subject.options[:sort]).to eq({ 'title.en' => 1 }) }

  end

end
