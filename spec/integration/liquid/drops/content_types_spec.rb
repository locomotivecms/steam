require 'spec_helper'

require_relative '../../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::Liquid::Drops::ContentTypes do

  describe 'access a content type through a variable' do

    let(:source) { <<-EOF
  {% assign myContentType = 'songs' %}
  {% for song in contents[myContentType] %}
    <span>{{ song.title }}</span>
  {% endfor %}
  EOF
    }

    let(:page)      { nil }
    let(:site)      { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
    let(:services)  { Locomotive::Steam::Services.build_instance }
    let(:assigns)   { { 'contents' => Locomotive::Steam::Liquid::Drops::ContentTypes.new, 'fullpath' => '/', 'current_page' => page } }
    let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services }) }

    before {
      services.locale = :en
      services.repositories.adapter       = adapter
      services.repositories.current_site  = site
    }

    subject { render_template(source, context) }

    shared_examples_for 'listing content entries of a dynamic content type' do

      it { is_expected.to match /<span>Song #1<\/span>/ }

    end

    context 'Filesystem' do

      it_should_behave_like 'listing content entries of a dynamic content type' do

        let(:site_id)   { 1 }
        let(:adapter)   { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

      end

    end

    context 'MongoDB' do

      it_should_behave_like 'listing content entries of a dynamic content type' do

        let(:site_id)   { mongodb_site_id }
        let(:adapter)   { Locomotive::Steam::MongoDBAdapter.new(database: mongodb_database, hosts: ['127.0.0.1:27017']) }

      end

    end

  end

end
