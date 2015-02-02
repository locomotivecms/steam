require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Consume do

  let(:template)  { '{% consume blog from "http://blog.locomotiveapp.org" %}{% endconsume %}' }
  let(:assigns)   { {} }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services }) }

  subject { render_template(template, context) }

  describe 'validating syntax' do

    let(:response)  { nil }
    before { allow(services.external_api).to receive(:consume).and_return(response) }

    describe 'validates a basic syntax' do
      it { expect { subject }.not_to raise_exception }
    end

    describe 'validates more complex syntax with attributes' do
      let(:template) { '{% consume blog from "http://www.locomotiveapp.org", username: "john", password: password_from_context %}{% endconsume %}' }
      it { expect { subject }.not_to raise_exception }
    end

    describe 'should parse the correct url with complex syntax with attributes' do
      let(:template) { '{% consume blog from "http://www.locomotiveapp.org" username: "john", password: "easyone" %}{% endconsume %}' }
      it { expect { subject }.not_to raise_exception }
    end

    describe 'raises an error if the syntax is incorrect' do
      let(:template) { '{% consume blog http://www.locomotiveapp.org %}{% endconsume %}' }
      it { expect { subject }.to raise_exception }
    end

  end

  describe 'rendering' do

    let(:response) { { 'title' => 'Locomotive rocks!' } }
    before { allow(services.external_api).to receive(:consume).and_return(response) }

    describe 'assign the response into the liquid variable' do

      let(:template) { "{% consume blog from \"http://blog.locomotiveapp.org/api/read\" %}{{ blog.title }}{% endconsume %}" }
      it { is_expected.to eq 'Locomotive rocks!' }

    end

    describe 'assign the response into the liquid variable using a url from a variable' do

      let(:assigns)   { { 'url' => 'http://blog.locomotiveapp.org/api/read' } }
      let(:template)  { "{% consume blog from url %}{{ blog.title }}{% endconsume %}" }
      it { is_expected.to eq 'Locomotive rocks!' }

    end

    describe 'accept options for the web service' do

      let(:assigns)     { { 'secret_password' => 'bar' } }
      let(:template) { "{% consume blog from \"http://blog.locomotiveapp.org/api/read\", username: 'foo', password: secret_password %}{{ blog.title }}{% endconsume %}" }
      it { is_expected.to eq 'Locomotive rocks!' }

    end

  end

  describe 'timeout' do

    let(:response)  { { 'title' => 'first response' } }
    let(:url)       { 'http://blog.locomotiveapp.org/api/read' }
    let(:template)  { %{{% consume blog from "#{url}" timeout:5.0 %}{{ blog.title }}{% endconsume %}} }

    it 'should pass the timeout option to httparty' do
      expect(services.external_api).to receive(:consume).with(url, timeout: 5.0).and_return(response)
      subject
    end

    it 'should return the previous successful response if a timeout occurs' do
      allow(services.cache).to receive(:read).and_return(response)
      allow(services.external_api).to receive(:consume).and_raise(Timeout::Error)
      expect(subject).to eq 'first response'
    end

  end

end
