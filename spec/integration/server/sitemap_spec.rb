require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'sitemap.xml' do

    subject { get '/sitemap.xml'; last_response.body }

    before { allow(Time).to receive(:now).and_return(Time.zone.parse('2015/03/25 10:00:00')); }

    it 'checks if it looks valid' do
      expect(Nokogiri::XML(subject).errors.empty?).to eq true
      expect(subject.scan(/<url>/).size).to eq 45
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
  end

end
