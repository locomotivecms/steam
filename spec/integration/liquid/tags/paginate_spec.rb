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

  let(:site)      { Locomotive::Steam::Site.new(_id: site_id, locales: %w(en fr nb)) }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:assigns)   { { 'contents' => Locomotive::Steam::Liquid::Drops::ContentTypes.new } }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services }) }

  before {
    services.locale = :en
    services.repositories.adapter       = adapter
    services.repositories.current_site  = site
  }

  subject { render_template(source, context) }

  context 'Filesystem' do

    let(:site_id)   { 1 }
    let(:adapter)   { Locomotive::Steam::FilesystemAdapter.new(default_fixture_site_path) }

    it { is_expected.to eq '!RoR!MongoDB!Liquid!ReactJS!DCI' }

  end




  #   describe 'simple array' do

  #     subject { output }

  #     it { is_expected.to include '!RoR!MongoDB!Liquid!ReactJS!DCI' }
  #     it { is_expected.not_to include '!Bootstrap' }

  #     describe 'second page of results: display the last item' do

  #       let(:page) { 2 }
  #       it { is_expected.to include '!Bootstrap' }
  #       it { is_expected.not_to include '!RoR!MongoDB!Liquid!ReactJS!DCI' }

  #     end

  #   end

  #   describe 'array from a db collection' do

  #     let(:projects) { KindaDBCollection.new(['RoR', 'MongoDB', 'Liquid', 'ReactJS', 'DCI', 'Bootstrap']) }

  #     subject { output }

  #     it { is_expected.to include '!RoR!MongoDB!Liquid!ReactJS!DCI' }
  #     it { is_expected.not_to include '!Bootstrap' }

  #   end

  #   describe 'a very big collection' do

  #     let(:projects)  { (1..100).to_a }
  #     let(:page)      { 20 }
  #     let(:source)    { '{% paginate projects by 2, window_size: 10 %}{% assign _pagination = paginate %}{% endpaginate %}' }

  #     before  { output }
  #     subject { context['_pagination']['parts'] }

  #     it { expect(subject.first['title']).to eq 1 }
  #     it { expect(subject[1]['title']).to eq '&hellip;' }
  #     it { expect(subject[2]['title']).to eq 11 }
  #     it { expect(subject[21]['title']).to eq '&hellip;' }
  #     it { expect(subject.last['title']).to eq 50 }

  #   end

  #   describe ''

  # end

  # class KindaDBCollection < Struct.new(:collection)

  #   def paginate(options = {})
  #     total_pages = (collection.size.to_f / options[:per_page].to_f).to_f.ceil + 1
  #     offset = (options[:page] - 1) * options[:per_page]

  #     {
  #       collection:     collection[offset..(offset + options[:per_page]) - 1],
  #       current_page:   options[:page],
  #       previous_page:  options[:page] == 1 ? 1 : options[:page] - 1,
  #       next_page:      options[:page] == total_pages ? total_pages : options[:page] + 1,
  #       total_entries:  collection.size,
  #       total_pages:    total_pages,
  #       per_page:       options[:per_page]
  #     }
  #   end

  #   def each(&block)
  #     collection.each(&block)
  #   end

  #   def method_missing(method, *args)
  #     collection.send(method, *args)
  #   end

  #   def to_liquid
  #     self
  #   end
  # end

end
