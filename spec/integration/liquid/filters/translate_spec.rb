require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Translate do

  let(:source) { "{{ 'welcome_message' | translate }}" }

  let(:site)        { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
  let(:services)    { Locomotive::Steam::Services.build_instance }
  let(:translator)  { services.translator }
  let(:assigns)     { {} }
  let(:context)     { ::Liquid::Context.new(assigns, {}, { services: services }) }

  before { services.locale = :en }

  subject { render_template(source, context) }

  context 'missing translation' do

    before { allow(translator).to receive(:translate).and_return(nil) }

    it { is_expected.to eq 'welcome_message' }

  end

  context 'existing translation' do

    before { allow(translator).to receive(:translate).and_return('Hello world') }

    it { is_expected.to eq 'Hello world' }

  end

  describe 'passing a locale and a scope' do

    before { allow(translator).to receive(:translate).and_return('Bonjour monde') }

    describe 'legacy syntax' do

      let(:source) { "{{ 'welcome_message' | translate: 'fr', 'locomotive.default' }}" }
      it { expect(translator).to receive(:translate).with('welcome_message', { 'locale' => 'fr', 'scope' => 'locomotive.default' }); subject }

    end

    describe 'new syntax' do

      let(:source) { "{{ 'welcome_message' | translate: locale: 'fr', scope: 'locomotive.default' }}" }
      it { expect(translator).to receive(:translate).with('welcome_message', { 'locale' => 'fr', 'scope' => 'locomotive.default' }); subject }

    end

    describe 'shortcut alias' do

      let(:source) { "{{ 'welcome_message' | t: 'fr', 'locomotive.default' }}" }
      it { expect(translator).to receive(:translate).with('welcome_message', { 'locale' => 'fr', 'scope' => 'locomotive.default' }); subject }

    end

  end

  describe 'pluralization' do

    let(:translation) { { 'en' => '{{ name }} has {{ count }} articles' } }
    before { expect(translator.repository).to receive(:group_by_key).and_return({ 'post_count_two' => translation }) }

    let(:source) { "{{ 'post_count' | translate: count: 2, name: 'John' }}" }
    it { expect(subject).to eq('John has 2 articles') }

  end

end
