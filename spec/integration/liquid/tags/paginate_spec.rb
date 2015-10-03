require 'spec_helper'

require_relative '../../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../../lib/locomotive/steam/adapters/mongodb.rb'

describe Locomotive::Steam::Liquid::Tags::Paginate do

  let(:source) { <<-EOF
{% paginate contents.songs by 5 %}
  {% for song in paginate.collection %}!{{ song.title }}{% endfor %}
  {{ paginate.next.url }}
{% endpaginate %}'
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

  shared_examples_for 'pagination' do

    it { is_expected.to match '!Song #1!Song #2!Song #3!Song #4!Song #5' }

    describe 'second page' do
      let(:page) { 2 }
      it { is_expected.to match '!Song #6!Song #7!Song #8' }
    end

    describe 'pagination of a has_many association' do

      let(:source) { <<-EOF
{% with_scope _slug: 'the-who' %}
{% assign band = contents.bands.first %}
{% endwith_scope %}
{% paginate band.songs by 1 %}
  -{% for song in paginate.collection %}!{{ song.title }}{% endfor %}-
{% endpaginate %}'
EOF
      }

      it { is_expected.to match '-!Song #5-' }

    end

  end

  context 'Filesystem' do

    it_should_behave_like 'pagination' do

      let(:site_id)   { 1 }
      let(:adapter)   { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

    end

  end

  context 'MongoDB' do

    it_should_behave_like 'pagination' do

      let(:site_id)   { mongodb_site_id }
      let(:adapter)   { Locomotive::Steam::MongoDBAdapter.new(database: 'steam_test', hosts: ['127.0.0.1:27017']) }

    end

  end

end
