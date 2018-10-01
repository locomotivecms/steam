require 'spec_helper'
require 'rack/csrf'

describe Locomotive::Steam::Liquid::Tags::ModelForm do

  before do
    allow(Rack::Csrf).to receive(:field).and_return('token')
    allow(Rack::Csrf).to receive(:token).and_return(42)
  end

  let(:path)      { '' }
  let(:env)       { {} }
  let(:request)   { instance_double('Request', env: env) }
  let(:source)    { "{% model_form 'newsletter_addresses' %}Newsletter Form{% endmodel_form %}" }
  let(:services)  { Locomotive::Steam::Services.build_instance(request) }
  let(:context)   { ::Liquid::Context.new({ 'path' => path }, {}, { services: services }) }

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

  describe 'json enabled' do

    let(:source) { "{% model_form 'newsletter_addresses', json: true %}Newsletter Form{% endmodel_form %}" }
    it { is_expected.to eq %(<form method="POST" enctype="multipart/form-data" action="/index.json"><input type="hidden" name="content_type_slug" value="newsletter_addresses" /><input type="hidden" name="token" value="42" />Newsletter Form</form>) }

    context 'rendered at /_app/foo/preview' do

      let(:path)  { '/_app/foo/preview/' }
      let(:env)   { { 'steam.mounted_on' => '/_app/foo/preview/' } }
      it { is_expected.to eq %(<form method="POST" enctype="multipart/form-data" action="/_app/foo/preview/index.json"><input type="hidden" name="content_type_slug" value="newsletter_addresses" /><input type="hidden" name="token" value="42" />Newsletter Form</form>) }

    end

    context 'rendered at /_app/foo/preview/contact' do

      let(:path)  { '/_app/foo/preview/contact' }
      let(:env)   { { 'steam.mounted_on' => '/_app/foo/preview/' } }
      it { is_expected.to eq %(<form method="POST" enctype="multipart/form-data" action="/_app/foo/preview/contact.json"><input type="hidden" name="content_type_slug" value="newsletter_addresses" /><input type="hidden" name="token" value="42" />Newsletter Form</form>) }

    end

  end

  describe 'specifying an action' do

    let(:source) { "{% model_form 'newsletter_addresses', action: 'foo/bar' %}Newsletter Form{% endmodel_form %}" }
    it { is_expected.to eq %(<form method="POST" enctype="multipart/form-data" action="/foo/bar"><input type="hidden" name="content_type_slug" value="newsletter_addresses" /><input type="hidden" name="token" value="42" />Newsletter Form</form>) }

    context 'mounted_on is not empty' do

      let(:env) { { 'steam.mounted_on' => '/_app/foo/preview' } }
      it { is_expected.to eq %(<form method="POST" enctype="multipart/form-data" action="/_app/foo/preview/foo/bar"><input type="hidden" name="content_type_slug" value="newsletter_addresses" /><input type="hidden" name="token" value="42" />Newsletter Form</form>) }

    end

  end

end
