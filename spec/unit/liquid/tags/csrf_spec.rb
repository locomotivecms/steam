require 'spec_helper'
require 'rack/csrf'

describe Locomotive::Steam::Liquid::Tags::Csrf do

  before do
    allow(Rack::Csrf).to receive(:field).and_return('token')
    allow(Rack::Csrf).to receive(:token).and_return(42)
  end

  let(:request)   { instance_double('Request', env: {}) }
  let(:services)  { Locomotive::Steam::Services.build_instance(request) }
  let(:context)   { ::Liquid::Context.new({}, {}, { services: services }) }

  subject { render_template(template, context) }

  describe 'csrf_param' do

    let(:template)  { '{% csrf_param %}' }
    it { is_expected.to eq '<input type="hidden" name="token" value="42" />' }

    context 'protection not enabled' do

      before { allow(services.configuration).to receive(:csrf_protection).and_return(false) }
      it { is_expected.to eq '' }

    end

  end

  describe 'rendering the meta tag used by ajax requests' do

    let(:template)  { '{% csrf_meta %}' }

    it { is_expected.to match '<meta name="csrf-param" content="token" />' }
    it { is_expected.to match '<meta name="csrf-token" content="42" />' }

    context 'protection not enabled' do

      before { allow(services.configuration).to receive(:csrf_protection).and_return(false) }
      it { is_expected.to eq '' }

    end

  end

end
