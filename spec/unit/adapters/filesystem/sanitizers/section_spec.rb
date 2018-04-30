require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizer.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizers/section.rb'
require_relative '../../../../../lib/locomotive/steam/errors.rb'

describe Locomotive::Steam::Adapters::Filesystem::Sanitizers::Section do

  let(:template_path) { 'spec/fixtures/default/app/views/sections/header.liquid' }
  let(:entity)    { instance_double('SectionEntity', template_path: template_path) }
  let(:site)    { instance_double('Site', _id: 1) }
  let(:scope)   { instance_double('Scope', site: site) }
  let(:sanitizer) { described_class.new }

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
          expect { subject }.to raise_error(Locomotive::Steam::ParsingRenderingError)
        end
      end
    end
  end
end
