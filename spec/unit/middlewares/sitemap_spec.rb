require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/sitemap'

describe Locomotive::Steam::Middlewares::Sitemap do

  let(:site)            { instance_double('Site', locales: ['en', 'fr'], default_locale: 'en') }
  let(:pages)           { [] }
  let(:page_repository) { instance_double('PageRepository', published: pages, :locale= => 'en') }
  let(:app)             { ->(env) { [200, env, 'app'] }}
  let(:middleware)      { described_class.new(app) }

  before do
    allow_any_instance_of(described_class).to receive(:site).and_return(site)
    allow_any_instance_of(described_class).to receive(:base_url).and_return('http://localhost/')
    allow_any_instance_of(described_class).to receive(:page_repository).and_return(page_repository)
  end

  describe '#call' do

    let(:env) { { 'PATH_INFO' => '/sitemap.xml', 'steam.page' => nil, 'steam.site' => site } }
    subject { middleware.call(env) }

    describe 'no pages' do

      it 'renders a blank sitemap' do
        is_expected.to eq [200, { "Content-Type"=>"text/plain" }, ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\" xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">\n\n</urlset>\n"]]
      end

    end

    describe 'only layouts' do

      let(:pages) { [instance_double('Page', index?: false, not_found?: false, layout?: true)] }

      it 'renders a blank sitemap' do
        is_expected.to eq [200, { "Content-Type"=>"text/plain" }, ["<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\" xmlns:xhtml=\"http://www.w3.org/1999/xhtml\">\n\n</urlset>\n"]]
      end

    end

  end

end
