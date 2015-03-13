require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Site do

  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new({}, {}, { services: services }) }
  let(:site)      { instance_double('Site', name: 'Locomotive', domains: ['acme.org'], seo_title: 'seo title', meta_keywords: 'keywords', meta_description: 'description', localized_attributes: {}) }
  let(:drop)      { described_class.new(site).tap { |d| d.context = context } }

  subject { drop }

  it 'gives access to general attributes' do
    expect(subject.name).to eq 'Locomotive'
    expect(subject.seo_title).to eq 'seo title'
    expect(subject.meta_keywords).to eq 'keywords'
    expect(subject.meta_description).to eq 'description'
    expect(subject.domains).to eq ['acme.org']
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
