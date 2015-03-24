require File.dirname(__FILE__) + '/../integration_helper'

describe Locomotive::Steam::Server do

  include Rack::Test::Methods

  def app
    run_server
  end

  describe 'sitemap.xml' do

    subject { get '/sitemap.xml'; last_response.body }

    it 'displays code for the first time' do
      is_expected.to eq <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://example.org</loc>
    <priority>1.0</priority>
  </url>
  <url>
    <loc>http://example.org/articles</loc>
    <lastmod>:now</lastmod>
    <priority>0.9</priority>
  </url>
  <url>
    <loc>http://example.org/articles/hello-world</loc>
    <lastmod>:now</lastmod>
    <priority>0.9</priority>
  </url>
  <url>
    <loc>http://example.org/articles/lorem-ipsum</loc>
    <lastmod>:now</lastmod>
    <priority>0.9</priority>
  </url>
</urlset>
      EOF
    end

  end

end
