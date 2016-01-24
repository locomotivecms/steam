require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Metafields do

  let(:metafields)  { { 'analytics_id' => { 'default' => '42' }, 'street' => { 'en' => '7 Albert Camus Alley', 'fr' => '7 allée Albert Camus' } } }
  let(:schema)      { [ { fields: [{ name: 'analytics_id' }] }, { fields: [{ name: 'street', localized: true }, { name: 'country' }] }].as_json }
  let(:site)        { instance_double('Site', metafields: metafields, metafields_schema: schema) }
  let(:context)     { ::Liquid::Context.new({}, {}, { locale: 'en' }) }
  let(:drop)        { described_class.new(site).tap { |d| d.context = context } }

  describe 'calling a metafield' do

    context 'unknown field' do

      subject { drop.before_method(:unknown_field) }

      it { is_expected.to eq nil }

    end

    context 'not localized field' do

      context 'the value exists' do

        subject { drop.before_method(:analytics_id) }

        it { is_expected.to eq '42' }

      end

      context "the value doesn't exist" do

        subject { drop.before_method(:country) }

        it { is_expected.to eq nil }

      end

    end

    context 'localized field' do

      subject { drop.before_method(:street) }

      it { is_expected.to eq '7 Albert Camus Alley' }

      context 'in another locale' do

        let(:context) { ::Liquid::Context.new({}, {}, { locale: 'fr' }) }

        it { is_expected.to eq '7 allée Albert Camus' }

      end

      context 'in a locale with no translation' do

        let(:context) { ::Liquid::Context.new({}, {}, { locale: 'de' }) }

        it { is_expected.to eq nil }

      end

    end

  end

end
