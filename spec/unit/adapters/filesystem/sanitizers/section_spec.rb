require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizer.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizers/section.rb'
require_relative '../../../../../lib/locomotive/steam/errors.rb'

describe Locomotive::Steam::Adapters::Filesystem::Sanitizers::Section do

  let(:template_path) { 'spec/fixtures/default/app/views/sections/header.liquid' }
  let(:entity)        { instance_double('SectionEntity', template_path: template_path, definition: {}) }
  let(:site)          { instance_double('Site', _id: 1) }
  let(:scope)         { instance_double('Scope', site: site) }
  let(:sanitizer)     { described_class.new }

  before(:each) do
    sanitizer.setup(scope);
  end

  describe '#apply_to_entity' do

    subject { sanitizer.apply_to_entity(entity) }

    describe 'with correct json' do

      it 'sanitize entity' do
        expect(entity).to receive(:definition=).with(hash_including({ 'name' => 'header' }))
        expect(entity).to receive(:template=).with((<<-LIQUID
<h1> {{ section.settings.brand }} </h1>
<ul>
  {% for block in section.blocks %}
    <li>
      <a href="{{ block.settings.url }}" target="{% if block.settings.new_tab %}_blank{% endif %}">
        {{ block.settings.label }}
      </a>
    </li>
  {% endfor %}
</ul>
LIQUID
        ).gsub /^$\n/, '')
        expect(entity).to receive(:[]=).with(:site_id, 1)
        subject
      end
    end

    describe 'aliases' do

      before do
        expect(entity).to receive(:[]=).with(:site_id, 1)
        allow(entity).to receive(:template=)
      end

      context 'presets (section dropzone)' do

        let(:template_path) { 'spec/fixtures/default/app/views/sections/carousel.liquid' }

        it 'allow to alias presets' do
          expect(entity).to receive(:definition=).with(hash_including({ 'presets' => [{ "name" => "Carousel", "category" => "Content", "settings" => { "brand" => "Acme" }, "blocks" => [] }] }))
          subject
        end

      end

      context 'global content (global section)' do

        let(:template_path) { 'spec/fixtures/default/app/views/sections/footer.liquid' }

        it 'allow to alias default' do
          expect(entity).to receive(:definition=).with(hash_including({ 
            'default' => { 
              "settings" => { 
                "brand" => "MY COMPANY",
                "default_test" => "value",
                "other_default_test" => nil,
              }, 
              "blocks" => [
                { 
                  "type" => "link", 
                  "settings" => { 
                    "label" => "Link #1", 
                    "url" => "https://www.nocoffee.fr", 
                    "new_tab" => "false" 
                  } 
                },
                { 
                  "type" => "link", 
                  "settings" => { 
                    "label" => "Link #2", 
                    "url" => nil, 
                    "new_tab" => "true" 
                  } 
                },
                { 
                  "type" => "link", 
                  "settings" => { 
                    "label" => "Link text", 
                    "url" => "https://www.nocoffee.fr", 
                    "new_tab" => "true" 
                  } 
                },
              ]
            }
          }))
          subject
        end

      end

      context 'section default (standalone/global)' do
        let(:template_path) { 'spec/fixtures/default/app/views/sections/footer.liquid' }

        it 'has fallback for setting `default` key if not already defined in section settings or block settings `default` key' do
          expect(entity).to receive(:definition=).with(hash_including({ 
            'default' => { 
              "settings" => { 
                "brand" => "MY COMPANY",
                "default_test" => "value",
                "other_default_test" => nil,
              }, 
              "blocks" => [
                { 
                  "type" => "link", 
                  "settings" => { 
                    "label" => "Link #1", 
                    "url" => "https://www.nocoffee.fr", 
                    "new_tab" => "false" 
                  } 
                },
                { 
                  "type" => "link", 
                  "settings" => { 
                    "label" => "Link #2", 
                    "url" => nil, 
                    "new_tab" => "true" 
                  } 
                },
                { 
                  "type" => "link", 
                  "settings" => { 
                    "label" => "Link text", 
                    "url" => "https://www.nocoffee.fr", 
                    "new_tab" => "true" 
                  } 
                },
              ]
            }
          }))
          subject
        end

      end

    end

    describe 'errors' do

      before(:each) do
        allow(entity).to receive(:[]=)
      end

      describe 'in json header' do

        let(:template_path) { 'spec/fixtures/errors/section_bad_json_header.liquid' }

        it 'should throw an error' do
          expect { subject }.to raise_error(Locomotive::Steam::ParsingRenderingError)
        end
      end

      describe 'json content' do

        let(:template_path) { 'spec/fixtures/errors/section_bad_json_content.liquid' }

        it 'should throw an error' do
          expect { subject }.to raise_error(Locomotive::Steam::JsonParsingError)
        end
      end

    end

  end

end
