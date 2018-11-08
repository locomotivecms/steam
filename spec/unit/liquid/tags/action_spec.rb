require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Action do

  let(:site)      { instance_double('Site', default_locale: 'en') }
  let(:source)    { '{% action "random Javascript action" %}var foo = 42; setProp("foo", foo);{% endaction %}' }
  let(:assigns)   { {} }
  let(:registers) { { services: services } }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new(assigns, {}, registers) }

  before { allow(services).to receive(:current_site).and_return(site) }

  subject { render_template(source, context) }

  describe 'parsing' do

    describe 'raises an error if the syntax is incorrect' do
      let(:source) { '{% action %}{% endaction %}' }
      it { expect { subject }.to raise_exception(Liquid::SyntaxError) }
    end

  end

  describe 'rendering' do

    it { is_expected.to eq '' }

    it { subject; expect(context['foo']).to eq 42.0 }

    describe 'uploaded file' do

      let(:registers) { { services: services, params: { 'my_file' => { 'tempfile' => Tempfile.new('my_file') } } } }
      let(:source)  { '{% action "uploaded file" %}setProp("path", params.my_file.tempfile);{% endaction %}' }

      it { subject; expect(context['path']).to match /\/my_file/ }

    end

  end

end
