require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Authorize do

  let(:site)        { instance_double('Site', default_locale: 'en', prefix_default_locale: false) }
  let(:page)        { instance_double('Page', fullpath: 'me/sign_in', templatized?: false) }
  let(:page_handle) { "'sign_in'" }
  let(:source)      { "{% authorize 'accounts', #{page_handle} %}Hello world!" }
  let(:assigns)     { {} }
  let(:services)    { Locomotive::Steam::Services.build_instance }
  let(:context)     { ::Liquid::Context.new(assigns, {}, { services: services }) }

  before {
    allow(services).to receive(:current_site).and_return(site)
    allow(services.page_finder).to receive(:by_handle).and_return(page)
  }

  subject { render_template(source, context) }

  describe 'validating syntax' do

    describe 'no page handle' do
      let(:source) { '{% authorize accounts %}' }
      it { expect { subject }.to raise_exception(Liquid::SyntaxError) }
    end

  end

  describe '#render' do

    context 'unauthenticated account' do

      it 'redirects to the sign in page' do
        expect { subject }.to raise_error(Locomotive::Steam::RedirectionException, 'Redirect to /me/sign_in')
      end

    end

    context 'authenticated account' do

      let(:assigns) { { 'current_account' => liquid_instance_double('Account', {}) } }

      it 'renders the page' do
        expect(subject).to eq 'Hello world!'
      end

    end

  end

end
