require 'spec_helper'

describe Locomotive::Steam::Services::UrlBuilder do

  let(:site)    { instance_double('Site', default_locale: 'en') }
  let(:locale)  { 'en' }
  let(:service) { Locomotive::Steam::Services::UrlBuilder.new(site, locale) }

  describe '#url_for' do

    let(:page) { instance_double('AboutUs', fullpath: 'about-us', templatized?: false) }

    subject { service.url_for(page) }

    it { is_expected.to eq '/about-us' }

    describe 'a locale different from the default one' do

      let(:locale) { 'fr' }
      it { is_expected.to eq '/fr/about-us' }

    end

    describe 'no need to put the index slug' do

      let(:page) { instance_double('Index', fullpath: 'index', templatized?: false) }
      it { is_expected.to eq '/' }

      context 'different locale' do

        let(:locale) { 'fr' }
        it { is_expected.to eq '/fr' }

      end

    end

    describe 'templatized page' do

      let(:article) { instance_double('Article', _slug: 'hello-world') }
      let(:page)    { instance_double('Template', fullpath: 'articles/content-type-template', templatized?: true, content_entry: article) }
      it { is_expected.to eq '/articles/hello-world' }

    end

  end

end
