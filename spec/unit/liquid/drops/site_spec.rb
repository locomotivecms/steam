require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Site do

  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new({}, {}, { services: services }) }
  let(:site)      { instance_double('Site', name: 'Locomotive', domains: ['acme.org'], seo_title: 'seo title', meta_keywords: 'keywords', meta_description: 'description') }
  let(:drop)      { Locomotive::Steam::Liquid::Drops::Site.new(site).tap { |d| d.context = context } }

  subject { drop }

  describe 'general attributes' do

    it { expect(subject.name).to eq 'Locomotive' }
    it { expect(subject.seo_title).to eq 'seo title' }
    it { expect(subject.meta_keywords).to eq 'keywords' }
    it { expect(subject.meta_description).to eq 'description' }
    it { expect(subject.domains).to eq ['acme.org'] }

  end

  describe '#index' do

    let(:index) { instance_double('IndexPage', to_liquid: { 'title' => 'Home page' }) }

    before do
      allow(services.repositories.page).to receive(:root).and_return(index)
    end

    it { expect(subject.index).to eq({ 'title' => 'Home page' }) }

  end

  describe '#pages' do

    let(:pages) do
      [
        instance_double('AboutUsPage', to_liquid: { 'title' => 'About us' }),
        instance_double('ContactPage', to_liquid: { 'title' => 'Contact' })
      ]
    end

    before do
      allow(services.repositories.page).to receive(:all).and_return(pages)
    end

    it { expect(subject.pages).to eq([{ 'title' => 'About us' }, { 'title' => 'Contact' }]) }

  end

end
