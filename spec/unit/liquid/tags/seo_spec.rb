require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::SEO do

  let(:page)          { nil }
  let(:content_entry) { nil }

  let(:site)      { liquid_instance_double('Site', name: 'Acme', seo_title: 'Acme (SEO)', meta_description: 'A short site description', meta_keywords: 'test only cat dog') }
  let(:assigns)   { { 'site' => site, 'page' => page, 'content_entry' => content_entry } }
  let(:context)   { ::Liquid::Context.new(assigns, {}, {}) }

  subject { render_template(source, context).strip }

  describe 'seo' do

    let(:source) { '{% seo %}' }
    it { is_expected.to include '<title>Acme (SEO)</title>' }
    it { is_expected.to include %Q[<meta name="description" content="A short site description">] }
    it { is_expected.to include %Q[<meta name="keywords" content="test only cat dog">] }

  end

  describe 'seo_title' do

    let(:source) { '{% seo_title %}' }

    describe 'no page' do

      it { is_expected.to eq '<title>Acme (SEO)</title>' }

      describe 'no seo_title site property' do

        let(:site) { liquid_instance_double('Site', name: 'Acme', seo_title: nil, meta_description: 'A short site description', meta_keywords: 'test only cat dog') }
        it { is_expected.to eq '<title>Acme</title>' }

      end

    end

    describe 'with a page' do

      let(:page) { liquid_instance_double('Page', seo_title: 'Snow!') }
      it { is_expected.to eq '<title>Snow!</title>' }

    end

    describe 'with a content entry' do

      let(:content_entry) { liquid_instance_double('Entry', seo_title: 'Snow!') }
      it { is_expected.to eq '<title>Snow!</title>' }

    end

  end

  describe 'seo_metadata' do

    let(:source) { '{% seo_metadata %}' }

    describe 'no page' do

      it { is_expected.to include %Q[<meta name="description" content="A short site description">] }
      it { is_expected.to include %Q[<meta name="keywords" content="test only cat dog">] }

    end

    describe 'with a page' do

      let(:page) { liquid_instance_double('Page', meta_description: "It's snowing", meta_keywords: 'snow') }
      it { is_expected.to include %Q[<meta name="description" content="It's snowing">] }
      it { is_expected.to include %Q[<meta name="keywords" content="snow">] }

    end

    describe 'with a content entry' do

      let(:content_entry) { liquid_instance_double('Entry', meta_description: "It's snowing", meta_keywords: 'snow') }
      it { is_expected.to include %Q[<meta name="description" content="It's snowing">] }
      it { is_expected.to include %Q[<meta name="keywords" content="snow">] }

    end

  end

end
