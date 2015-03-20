require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Paginate do

  let(:source) { <<-EOF
{% paginate projects by 5 %}
  {% for project in paginate.collection %}!{{ project }}{% endfor %}
  {{ paginate.next.url }}
{% endpaginate %}'
EOF
  }

  let(:projects)  { ['RoR', 'MongoDB', 'Liquid', 'ReactJS', 'DCI', 'Bootstrap'] }
  let(:page)      { 1 }
  let(:assigns)   { { 'projects' => projects, 'current_page' => page, 'fullpath' => '/' } }
  let(:context)   { ::Liquid::Context.new(assigns, {}, {}) }
  let(:output)    { render_template(source, context) }

  describe 'parsing' do

    subject { parse_template(source) }

    describe 'wrong syntax' do

      let(:source) { '{% paginate projects %}{% endpaginate %}' }
      it { expect { subject }.to raise_error(::Liquid::SyntaxError, 'Liquid syntax error: Valid syntax: paginate <collection> by <number>') }

    end

    describe 'with options for the pagination' do

      let(:source)  { '{% paginate projects by 2, window_size: 4 %}{% endpaginate %}' }
      let(:block)   { subject.root.nodelist.first }
      it { expect(block.send(:window_size)).to eq 4 }

    end

  end

  describe 'rendering' do

    describe 'nil array' do

      let(:projects) { nil }

      subject { output }

      it { expect { subject }.to raise_error(::Liquid::ArgumentError, "Liquid error: Cannot paginate 'projects'. Not found.") }

    end

    describe 'simple array' do

      subject { output }

      it { is_expected.to include '!RoR!MongoDB!Liquid!ReactJS!DCI' }
      it { is_expected.not_to include '!Bootstrap' }

      describe 'second page of results: display the last item' do

        let(:page) { 2 }
        it { is_expected.to include '!Bootstrap' }
        it { is_expected.not_to include '!RoR!MongoDB!Liquid!ReactJS!DCI' }

      end

    end

    describe 'array from a db collection' do

      let(:projects) { KindaDBCollection.new(['RoR', 'MongoDB', 'Liquid', 'ReactJS', 'DCI', 'Bootstrap']) }

      subject { output }

      it { is_expected.to include '!RoR!MongoDB!Liquid!ReactJS!DCI' }
      it { is_expected.not_to include '!Bootstrap' }

    end

    describe 'a very big collection' do

      let(:projects)  { (1..100).to_a }
      let(:page)      { 20 }
      let(:source)    { '{% paginate projects by 2, window_size: 10 %}{% assign _pagination = paginate %}{% endpaginate %}' }

      before  { output }
      subject { context['_pagination']['parts'] }

      it { expect(subject.first['title']).to eq 1 }
      it { expect(subject[1]['title']).to eq '&hellip;' }
      it { expect(subject[2]['title']).to eq 11 }
      it { expect(subject[21]['title']).to eq '&hellip;' }
      it { expect(subject.last['title']).to eq 50 }

    end

    describe ''

  end

  class KindaDBCollection < Struct.new(:collection)

    def paginate(options = {})
      total_pages = (collection.size.to_f / options[:per_page].to_f).to_f.ceil + 1
      offset = (options[:page] - 1) * options[:per_page]

      {
        collection:     collection[offset..(offset + options[:per_page]) - 1],
        current_page:   options[:page],
        previous_page:  options[:page] == 1 ? 1 : options[:page] - 1,
        next_page:      options[:page] == total_pages ? total_pages : options[:page] + 1,
        total_entries:  collection.size,
        total_pages:    total_pages,
        per_page:       options[:per_page]
      }
    end

    def each(&block)
      collection.each(&block)
    end

    def method_missing(method, *args)
      collection.send(method, *args)
    end

    def to_liquid
      self
    end
  end

end
