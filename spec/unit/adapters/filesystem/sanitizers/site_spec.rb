require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizer.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizers/site.rb'

describe Locomotive::Steam::Adapters::Filesystem::Sanitizers::Site do

  let(:schema)    { nil }
  let(:entity)    { instance_double('SiteEntity', metafields_schema: schema) }
  let(:sanitizer) { described_class.new }

  describe '#apply_to_entity' do

    subject { sanitizer.apply_to_entity(entity) }

    it { expect(entity).to receive(:metafields_schema=).with(nil); subject }

  end

  describe '#clean_metafields_schema' do

    subject { sanitizer.send(:clean_metafields_schema, schema) }

    it { is_expected.to eq nil }

    describe 'with a schema' do

      # see the metafields_schema.yml in the fixtures folder
      let(:schema) { {:Social=>{:name=>{:fr=>"Social (FR)"}, :position=>1, :fields=>["Facebook ID", "Google ID"]}, :Github=>{:position=>0, :fields=>{:"API url"=>{:name=>{:fr=>"Url de l'API"}, :type=>"string", :default=>"https://api.github.com/repos/locomotivecms/engine/issues?state=opened"}, :"Expire in"=>{:name=>{:fr=>"Expire dans"}, :hint=>{:en=>"Cache - In milliseconds", :fr=>"Cache - En millisecondes"}, :type=>"integer", :min=>0, :max=>3600}}}} }

      it 'loads the full schema' do
        # First namespace
        expect(subject[0][:name]).to eq(default: 'Social', fr: 'Social (FR)')
        expect(subject[0][:position]).to eq 1
        expect(subject[0][:fields]).to eq([{ name: { default: 'Facebook ID' } }, { name: { default: 'Google ID' } }])

        # Second namespace
        expect(subject[1][:name]).to eq(default: 'Github')
        expect(subject[1][:position]).to eq 0
        expect(subject[1][:fields].count).to eq 2
        expect(subject[1][:fields][0]).to eq(name: { default: 'API url', fr: "Url de l'API" }, type: 'string', default: 'https://api.github.com/repos/locomotivecms/engine/issues?state=opened')
      end

    end

  end

end
