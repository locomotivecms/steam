require 'spec_helper'
require 'rack/csrf'

describe Locomotive::Steam::Liquid::Tags::ModelForm do

  before do
    allow(Rack::Csrf).to receive(:field).and_return('token')
    allow(Rack::Csrf).to receive(:token).and_return(42)
  end

  let(:request)   { instance_double('Request', env: {}) }
  let(:source)    { "{% model_form 'newsletter_addresses' %}Newsletter Form{% endmodel_form %}" }
  let(:services)  { Locomotive::Steam::Services.build_instance(request) }
  let(:context)   { ::Liquid::Context.new({}, {}, { services: services }) }

  subject { render_template(source, context) }

  it { is_expected.to eq %(<form method="POST" enctype="multipart/form-data"><input type="hidden" name="content_type_slug" value="newsletter_addresses" /><input type="hidden" name="token" value="42" />Newsletter Form</form>) }

  describe 'with a different dom id and css class' do

    let(:source) { "{% model_form 'newsletter_addresses', id: 'my-form', class: 'col-md-12' %}Newsletter Form{% endmodel_form %}" }
    it { is_expected.to eq %(<form method="POST" enctype="multipart/form-data" id="my-form" class="col-md-12"><input type="hidden" name="content_type_slug" value="newsletter_addresses" /><input type="hidden" name="token" value="42" />Newsletter Form</form>) }

  end

  describe 'using callbacks' do

    let(:source) { "{% model_form 'newsletter_addresses', success: '/success', error: '/error' %}Newsletter Form{% endmodel_form %}" }
    it { is_expected.to include %(<input type="hidden" name="success_callback" value="/success" />) }
    it { is_expected.to include %(<input type="hidden" name="error_callback" value="/error" />) }

  end

end
