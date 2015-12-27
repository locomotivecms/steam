require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Translate do

  let(:source) { "{{ 'welcome_message' | translate }}" }

  let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
  let(:services)    { Locomotive::Steam::Services.build_instance }
  let(:translator)  { services.translator }
  let(:assigns)     { {} }
  let(:context)     { ::Liquid::Context.new(assigns, {}, { services: services }) }

  before {
    services.locale = :en
    allow(translator).to receive(:translate).and_return(translation)
  }

  subject { render_template(source, context) }

  context 'missing translation' do

    let(:translation) { nil }

    it { is_expected.to eq 'welcome_message' }

  end

  context 'existing translation' do

    let(:translation) { 'Hello world' }

    it { is_expected.to eq 'Hello world' }

  end

  context 'passing a locale and a scope' do

    let(:translation) { 'Bonjour monde' }

    describe 'legacy syntax' do

      let(:source) { "{{ 'welcome_message' | translate: 'fr', 'locomotive.default' }}" }
      it { expect(translator).to receive(:translate).with('welcome_message', 'locale' => 'fr', 'scope' => 'locomotive.default'); subject }

    end

    describe 'new syntax' do

      let(:source) { "{{ 'welcome_message' | translate: locale: 'fr', scope: 'locomotive.default' }}" }
      it { expect(translator).to receive(:translate).with('welcome_message', 'locale' => 'fr', 'scope' => 'locomotive.default'); subject }

    end

  end

end
