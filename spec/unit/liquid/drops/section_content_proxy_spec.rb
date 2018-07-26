require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::SectionContentProxy do

  let(:url_finder_service) { instance_double('UrlFinderService') }
  let(:services)  { instance_double('Services', url_finder: url_finder_service) }
  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:context)   { ::Liquid::Context.new({}, {}, { locale: 'en', services: services, site: site }) }
  let(:drop)      { described_class.new(content, settings).tap { |d| d.context = context } }

  describe 'text type setting' do

    let(:settings)  { [{ 'id' => 'title', 'type' => 'text' }] }
    let(:content)   { { 'title' => %(Click <a href="//locomotive/_locomotive-link/aaaa">here</a>) } }

    subject { drop.before_method(:title) }

    it 'calls the url_finder_service to transform encoded links to existing urls' do
      expect(url_finder_service).to receive(:decode_urls_for).with(%(Click <a href="//locomotive/_locomotive-link/aaaa">here</a>)).and_return('done')
      is_expected.to eq 'done'
    end

  end

  describe 'url type setting' do

    let(:settings)  { [{ 'id' => 'link', 'type' => 'url' }] }
    let(:content)   { { 'link' => { 'type' => 'page', 'value' => 42, 'new_window' => true } } }
    let(:page)      { instance_double('Page') }

    before do
      expect(url_finder_service).to receive(:url_for).with({ 'type' => 'page', 'value' => 42, 'new_window' => true }).and_return(['/foo/bar', true])
    end

    subject { drop.before_method(:link).to_s }

    it 'returns the url to the page' do
      is_expected.to eq '/foo/bar'
    end

    context 'it knows if the link has to be opened in a new window or not' do

      subject { drop.before_method(:link).new_window }

      it { is_expected.to eq true }

    end

  end

end
