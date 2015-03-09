require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::ContentTypes do

  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new({}, {}, { services: services }) }
  let(:drop)      { described_class.new.tap { |d| d.context = context } }

  before do
    allow(services.repositories.content_type).to receive(:by_slug).with('articles').and_return(true)
  end

  it { expect(drop.before_method('articles')).not_to eq nil }

  context 'content type not found' do

    before do
      allow(services.repositories.content_type).to receive(:by_slug).with('articles').and_return(nil)
    end

    it { expect(drop.before_method('articles')).to eq nil }

  end

end
