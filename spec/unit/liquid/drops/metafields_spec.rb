require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Metafields do

  let(:metafields)  { { 'my_namespace' => { 'analytics_id' => { 'default' => '42' }, 'street' => { 'en' => '7 Albert Camus Alley', 'fr' => '7 allée Albert Camus' } } } }
  let(:schema)      { [ { 'name' => 'my_namespace', fields: [{ name: 'analytics_id', position: 1 }, { name: 'street', localized: true, position: 0 }, { name: 'country', :position => 2 }] }].as_json }
  let(:site)        { instance_double('Site', metafields: metafields, metafields_schema: schema) }
  let(:context)     { ::Liquid::Context.new({}, {}, { locale: 'en' }) }
  let(:drop)        { described_class.new(site).tap { |d| d.context = context } }

  describe 'fields' do

    let(:namespace) { drop.before_method(:my_namespace).tap { |d| d.context = context } }

    it 'gives the number of the fields' do
      expect(namespace.size).to eq 3
    end

    it 'iterates over the fields and keeps the order' do
      list = []
      namespace.each { |el| list << el['name'] }
      expect(list).to eq(['street', 'analytics_id', 'country'])
    end

  end

  describe 'calling a metafield' do

    context 'unknown namespace' do

      subject { drop.before_method(:unknown_namespace) }

      it { is_expected.to eq nil }

    end

    context 'existing namespace' do

      let(:namespace) { drop.before_method(:my_namespace).tap { |d| d.context = context } }

      context 'unknown field' do

        subject { namespace.before_method(:unknown_field) }

        it { is_expected.to eq nil }

      end

      context 'not a localized field' do

        context 'the value exists' do

          subject { namespace.before_method(:analytics_id) }

          it { is_expected.to eq '42' }

          context 'the value exists but is an empty string' do

            let(:metafields)  { { 'my_namespace' => { 'analytics_id' => { 'default' => '' }, 'street' => { 'en' => '7 Albert Camus Alley', 'fr' => '7 allée Albert Camus' } } } }
            it { is_expected.to eq nil }

          end

        end



        context "the value doesn't exist" do

          subject { namespace.before_method(:country) }

          it { is_expected.to eq nil }

        end

      end

      context 'localized field' do

        subject { namespace.before_method(:street) }

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

end
