require 'spec_helper'

describe Locomotive::Steam::Decorators::TemplateDecorator do

  let(:template_path)   { 'template.liquid' }
  let(:page)            { instance_double('Page', localized_attributes: [], template_path: template_path) }
  let(:locale)          { 'fr' }
  let(:default_locale)  { 'en' }
  let(:decorated)       { described_class.new(page, locale, default_locale) }

  describe '#liquid_source' do

    let(:content) { 'Lorem ipsum' }

    before { allow(File).to receive(:read).and_return(content) }

    subject { decorated.liquid_source.strip }

    it { is_expected.to eq 'Lorem ipsum' }

    context 'Raw template' do

      let(:page) { instance_double('Page', localized_attributes: [:source], source: { en: 'Lorem ipsum [EN]', fr: '' }) }

      it { is_expected.to eq 'Lorem ipsum [EN]' }

    end

    context 'HAML file' do

      let(:template_path) { 'template.liquid.haml' }
      let(:content) { '%p Lorem ipsum' }

      it { is_expected.to eq '<p>Lorem ipsum</p>' }

      context 'incorrect HAML syntax' do

        let(:content) { "foo\n  %p TEST" }

        it 'raises an error' do
          expect { subject }.to raise_error Locomotive::Steam::RenderError
        end

      end

    end

  end

end
