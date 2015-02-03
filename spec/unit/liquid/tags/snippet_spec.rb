require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Snippet do

  let(:snippet)       { instance_double('Snippet', source: 'built by NoCoffee') }
  let(:source)        { 'Locomotive {% include footer %}' }
  let(:repositories)  { Locomotive::Steam::Repositories.build_instance(nil) }

  before { allow(repositories.snippet).to receive(:by_slug).and_return(snippet) }

  describe 'parsing' do

    let(:page)      { instance_double('Page') }
    let(:listener)  { Liquid::SimpleEventsListener.new }
    let(:options)   { { events_listener: listener, page: page, repositories: repositories } }

    let!(:template) { parse_template(source, options) }

    it { expect(listener.event_names.first).to eq :include }

    # describe 'with an editable_element inside', pending: true do

    #   let(:snippet) { instance_double('Snippet', source: '{% editable_text company %}built by NoCoffee{% endeditable_text %}') }

    #   it { expect(listener.events.size).to eq 2 }

    # end

  end

  describe 'rendering' do

    let(:context) { ::Liquid::Context.new({}, {}, { repositories: repositories }) }

    subject       { render_template(source, context) }

    it { is_expected.to eq 'Locomotive built by NoCoffee' }

  end

end
