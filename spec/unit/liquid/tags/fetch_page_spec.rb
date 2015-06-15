require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::FetchPage do

  let(:source)        { "{% fetch_page about_us as a_page %}{{ a_page.title }}" }
  let(:assigns)       { {} }
  let(:repositories)  { Locomotive::Steam::Services.build_instance.repositories }
  let(:context)       { ::Liquid::Context.new(assigns, {}, { repositories: repositories }) }

  let(:page)  { instance_double('Page', to_liquid: { 'title' => 'About Us' }) }
  before      { allow(repositories.page).to receive(:by_handle).and_return(page) }

  subject { render_template(source, context) }

  describe 'validating syntax' do

    it { expect { subject }.not_to raise_exception }

    describe 'raises an error if the syntax is incorrect' do
      let(:source) { "{% fetch_page 'about_us' %}{{ a_page.title }}" }
      it { expect { subject }.to raise_exception(::SyntaxError) }
    end

  end

  describe 'rendering' do

    it { is_expected.to eq 'About Us' }

    describe 'no page found' do

      let(:page) { nil }
      it { is_expected.to eq '' }

    end

  end

end
