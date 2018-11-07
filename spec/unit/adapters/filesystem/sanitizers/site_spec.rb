require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizer.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizers/site.rb'

describe Locomotive::Steam::Adapters::Filesystem::Sanitizers::Site do

  let(:schema)    { nil }
  let(:routes)    { nil }
  let(:entity)    { instance_double('SiteEntity', metafields_schema: schema, routes: routes) }
  let(:sanitizer) { described_class.new }

  describe '#apply_to_entity' do

    subject { sanitizer.apply_to_entity(entity) }

    it 'modifies the entity' do
      expect(entity).to receive(:metafields_schema=).with(nil)
      expect(entity).to receive(:routes=).with([])
      subject
    end

  end

  describe '#build_routes' do

    let(:routes) { nil }

    subject { sanitizer.send(:build_routes, routes) }

    it { is_expected.to eq [] }

    describe 'various formats of the routes' do

      let(:routes) { [{ '/blog/:year/:month' => 'blog' }, { 'route' => '/products/:category/:slug', 'page_handle' => 'product' }] }

      it { is_expected.to eq([
        { 'route' => '/blog/:year/:month', 'page_handle' => 'blog' },
        { 'route' => '/products/:category/:slug', 'page_handle' => 'product' }
      ]) }

    end

  end

  describe '#clean_metafields_schema' do

    subject { sanitizer.send(:clean_metafields_schema, schema) }

    it { is_expected.to eq nil }

    describe 'with a schema' do

      # see the metafields_schema.yml in the fixtures folder
      let(:schema) { {
        :social => {
          :label    => { :fr=>"Social (FR)" },
          :position => 1,
          :fields   => ["facebook_id", "google_id"]
        },
        :github => {
          :position => 0,
          :fields   => {
            :api_url    => { :label => "API Url", :type => "string", :hint => "API endpoint" },
            :expires_in => { :label => { :en => "Expires in", :fr => "Expire dans" }, :hint => { :en => "Cache - In milliseconds", :fr => "Cache - En millisecondes" }, :type => "integer", :min => 0, :max => 3600 }
          }
        },
        :theme => {
          :fields => [
            { :color => { :label => 'Color', type: 'color' } },
            { :header => { :label => 'Header image', type: 'image' } }
          ]
        }
      } }

      it 'loads the full schema' do
        # First namespace
        expect(subject[0]['name']).to eq 'social'
        expect(subject[0]['label']).to eq('fr' => 'Social (FR)')
        expect(subject[0]['position']).to eq 1
        expect(subject[0]['fields']).to eq([{ 'name' => 'facebook_id', 'position' => 0 }, { 'name' => 'google_id', 'position' => 1 }])

        # Second namespace
        expect(subject[1]['label']).to eq('default' => 'github')
        expect(subject[1]['position']).to eq 0
        expect(subject[1]['fields'].count).to eq 2
        expect(subject[1]['fields'][0]).to eq('name' => 'api_url', 'position' => 0, 'label' => { 'default' => 'API Url' }, 'type' => 'string', 'hint' => { 'default' => 'API endpoint' })

        # Third namespace
        expect(subject[2]['label']).to eq('default' => 'theme')
        expect(subject[2]['fields'].count).to eq 2
        expect(subject[2]['fields'][0]).to eq('name' => 'color', 'position' => 0, 'label' => { 'default' => 'Color' }, 'type' => 'color')
        expect(subject[2]['fields'][1]).to eq('name' => 'header', 'position' => 1, 'label' => { 'default' => 'Header image' }, 'type' => 'image')
      end

      context 'label is a string instead of a hash' do

        let(:schema) { {:social=>{:label=>"Social", :position=>1, :fields=>["facebook_id", "google_id"]}, :github=>{:position=>0, :fields=>{:api_url=>{:label=>"API Url", :type=>"string", :hint=>"API endpoint"}, :expires_in=>{:label=>{:en=>"Expires in", :fr=>"Expire dans"}, :hint=>{:en=>"Cache - In milliseconds", :fr=>"Cache - En millisecondes"}, :type=>"integer", :min=>0, :max=>3600}}}} }

        it 'loads the full schema' do
          expect(subject[0]['label']).to eq('default' => 'Social')
        end

      end

    end

  end

end
