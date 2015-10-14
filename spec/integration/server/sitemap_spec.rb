require File.dirname(__FILE__) + '/../integration_helper'

require 'locomotive/steam/adapters/filesystem.rb'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'sitemap.xml' do

    let(:now) { Time.use_zone('America/Chicago') { Time.zone.local(2015, 'mar', 25, 10, 0) } }
    let(:env) { {} }

    subject { Timecop.freeze(now) { get('/sitemap.xml', {}, env) }; last_response.body }

    before { Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new.clear }

    it 'checks if it looks valid' do
      expect(Nokogiri::XML(subject).errors.empty?).to eq true
      expect(subject.scan(/<url>/).size).to eq 46
      expect(subject).to match("<loc>http://example.org/songs/song-number-2/band</loc>")
      expect(subject).to match((<<-EOF
  <url>
    <loc>http://example.org/fr/a-notre-sujet</loc>
    <lastmod>2015-03-25</lastmod>
    <priority>0.9</priority>
  </url>
      EOF
      ).strip)
    end

    context 'existing sitemap page' do

      let(:template)  { %{<?xml version="1.0" encoding="utf-8"?>OK</xml>} }
      let(:page)      { instance_double('Page', liquid_source: template, templatized?: false, redirect_url: false, to_liquid: template, not_found?: false, response_type: 'application/xml') }
      let(:env)       { { 'steam.page' => page } }

      it 'renders the existing sitemap page' do
        expect(subject).to eq %{<?xml version="1.0" encoding="utf-8"?>OK</xml>}
      end

    end

  end

end
