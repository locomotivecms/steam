require 'spec_helper'

describe Locomotive::Steam::UrlBuilderService do

  let(:prefix_default)  { false }
  let(:mounted_on)      { nil }
  let(:request)         { instance_double('Request', env: { 'steam.mounted_on' => mounted_on }) }
  let(:site)            { instance_double('Site', default_locale: 'en', prefix_default_locale: prefix_default) }
  let(:locale)          { 'en' }
  let(:service)         { described_class.new(site, locale, request) }

  describe '#url_for' do

    let(:page) { instance_double('AboutUs', fullpath: 'about-us', templatized?: false) }

    subject { service.url_for(page) }

    it { is_expected.to eq '/about-us' }

    describe 'the prefix_default_locale site property is enabled' do

      let(:prefix_default) { true }

      it { is_expected.to eq '/en/about-us' }

    end

    describe 'a locale different from the default one' do

      let(:locale) { 'fr' }
      it { is_expected.to eq '/fr/about-us' }

      context 'with a prefix' do
        let(:mounted_on) { '/foo' }
        it { is_expected.to eq '/foo/fr/about-us' }
      end

    end

    describe 'no need to put the index slug' do

      let(:page) { instance_double('Index', fullpath: 'index', templatized?: false) }
      it { is_expected.to eq '/' }

      context 'different locale' do

        let(:locale) { 'fr' }
        it { is_expected.to eq '/fr' }

        context 'with a prefix' do
          let(:mounted_on) { '/foo' }
          it { is_expected.to eq '/foo/fr' }
        end

      end

    end

    describe 'templatized page' do

      let(:article) { instance_double('Article', _slug: 'hello-world') }
      let(:page)    { instance_double('Template', fullpath: 'articles/content_type_template', templatized?: true, content_entry: article) }
      it { is_expected.to eq '/articles/hello-world' }

      context 'with a prefix' do
        let(:mounted_on) { '/foo' }
        it { is_expected.to eq '/foo/articles/hello-world' }
      end

    end

  end

end
