require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizer.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizers/section.rb'
require_relative '../../../../../lib/locomotive/steam/errors.rb'

describe Locomotive::Steam::Adapters::Filesystem::Sanitizers::Section do

  let(:entity)        { instance_double('SectionEntity', definition: definition) }
  let(:site)          { instance_double('Site', _id: 1) }
  let(:scope)         { instance_double('Scope', site: site) }
  let(:sanitizer)     { described_class.new }

  before(:each) { sanitizer.setup(scope) }

  describe '#apply_to_entity' do

    before { expect(entity).to receive(:[]=).with(:site_id, 1) }

    subject { sanitizer.apply_to_entity(entity) }

    describe 'aliases' do

      let(:definition) { load_section_definition('carousel', :yaml) }

      it 'allows to alias presets' do
        expect(subject.definition).to match(hash_including({ 'presets' => [{ 'name' => 'Carousel', 'category' => 'Content', 'settings' => { 'brand' => 'Acme' }, 'blocks' => [] }] }))
      end

    end

    describe 'fill_presets / set_default_values' do

      context 'global content (global section)' do

        let(:definition) { load_section_definition('footer') }

        it 'allows to alias default' do
          expect(subject.definition).to match(hash_including({ 'default' =>
            { 'settings' => { 'brand' => 'MY COMPANY', 'copyright' => '(c) NoCoffee' }, 'blocks' => [
              { 'type' => 'link', 'settings' => { 'label' => 'Link #1', 'url' => 'https://www.nocoffee.fr', 'new_tab' => true } },
              { 'type' => 'link', 'settings' => { 'label' => 'Link #2', 'url' => 'https://www.nocoffee.fr', 'new_tab' => true } },
              { 'type' => 'link', 'settings' => { 'label' => 'Link', 'url' => 'https://www.locomotivecms.com', 'new_tab' => true } }
            ]}
          }))
        end

      end

      context 'default (global) used also for dropzone_presets (DRY)' do

        let(:definition) { load_section_definition('header') }

        it 'copies the default settings to any dropzone preset' do
          expect(subject.definition).to match(hash_including({
            'presets' => [
              {
                'name'      => 'Default header',
                'category'  => 'Header',
                'settings'  => { 'brand' => 'MY COMPANY' },
                'blocks'    => [
                  { 'type' => 'link', 'settings' => { 'label' => 'Link #1', 'url' => 'https://www.nocoffee.fr', 'new_tab' => true } },
                  { 'type' => 'link', 'settings' => { 'label' => 'Link #2', 'url' => 'https://www.nocoffee.fr', 'new_tab' => true } },
                  { 'type' => 'link', 'settings' => { 'label' => 'Link', 'url' => 'https://www.locomotivecms.com', 'new_tab' => true } }
                ]
              }
            ]
          }))
        end

      end

    end

  end

  def load_section_definition(slug, format = :json)
    filepath  = File.join(default_fixture_site_path, 'app', 'views', 'sections', "#{slug}.liquid")
    content   = File.read(filepath)

    case format
    when :json
      match = content.match(Locomotive::Steam::JSON_FRONTMATTER_REGEXP)
      MultiJson.load(match[:json])
    when :yaml
      match = content.match(Locomotive::Steam::YAML_FRONTMATTER_REGEXP)
      YAML.load(match[:yaml])
    end
  end

end
