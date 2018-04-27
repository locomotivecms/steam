require 'spec_helper'

require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizer.rb'
require_relative '../../../../../lib/locomotive/steam/adapters/filesystem/sanitizers/section.rb'

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
    it 'sanitize entity' do
      expect(entity).to receive(:definition=).with(hash_including({"name" => 'header'}))
      expect(entity).to receive(:[]=).with(:site_id, 1)
      subject
    end
  end
end
