require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Consume do

  let(:source)  { '{% consume blog from "http://blog.locomotiveapp.org" %}{% endconsume %}' }
  let(:assigns)   { {} }
  let(:services)  { Locomotive::Steam::Services.build_instance }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { services: services }) }

  subject { render_template(source, context) }

  describe 'validating syntax' do

    let(:response)  { nil }
    before { allow(services.external_api).to receive(:consume).and_return(response) }

    describe 'validates a basic syntax' do
      it { expect { subject }.not_to raise_exception }
    end

    describe 'validates more complex syntax with attributes' do
      let(:source) { '{% consume blog from "http://www.locomotiveapp.org", username: "john", password: password_from_context %}{% endconsume %}' }
      it { expect { subject }.not_to raise_exception }
    end

    describe 'should parse the correct url with complex syntax with attributes' do
      let(:source) { '{% consume blog from "http://www.locomotiveapp.org" username: "john", password: "easyone" %}{% endconsume %}' }
      it { expect { subject }.not_to raise_exception }
    end

    describe 'raises an error if the syntax is incorrect' do
      let(:source) { '{% consume blog http://www.locomotiveapp.org %}{% endconsume %}' }
      it { expect { subject }.to raise_exception(Liquid::SyntaxError) }
    end

  end

  describe 'rendering' do

    let(:response) { { 'title' => 'Locomotive rocks!' } }
    before { allow(services.external_api).to receive(:consume).and_return(response) }

    describe 'assign the response into the liquid variable' do

      let(:source) { "{% consume blog from \"http://blog.locomotiveapp.org/api/read\" %}{{ blog.title }}{% endconsume %}" }
      it { is_expected.to eq 'Locomotive rocks!' }

    end

    describe 'assign the response into the liquid variable using a url from a variable' do

      let(:assigns)   { { 'url' => 'http://blog.locomotiveapp.org/api/read' } }
      let(:source)  { "{% consume blog from url %}{{ blog.title }}{% endconsume %}" }
      it { is_expected.to eq 'Locomotive rocks!' }

    end

    describe 'accept options for the web service' do

      let(:assigns)     { { 'secret_password' => 'bar' } }
      let(:source) { "{% consume blog from \"http://blog.locomotiveapp.org/api/read\", username: 'foo', password: secret_password %}{{ blog.title }}{% endconsume %}" }
      it { is_expected.to eq 'Locomotive rocks!' }

    end

    describe 'inside a loop' do

      let(:assigns) { { 'urls' => ['http://blog.locomotiveapp.org/api/read', 'http://blog.locomotiveapp.org/api/read'] } }
      let(:source)  { "{% for url in urls %}{% consume blog from url %}{{ blog.title }}{% endconsume %}{% endfor %}" }
      it { is_expected.to eq 'Locomotive rocks!Locomotive rocks!' }

    end

    describe "don't render it if the url is blank" do

      let(:source) { "{% consume blog from \"\" %}{{ blog.title }}{% endconsume %}" }
      it { is_expected.to eq '' }

    end

  end

  describe 'with an expires_in option' do

    let(:assigns)     { { 'secret_password' => 'bar' } }
    let(:source)      { "{% consume blog from \"http://blog.locomotiveapp.org/api/read\", username: 'foo', password: secret_password, expires_in: #{expires_in} %}{{ blog.title }}{% endconsume %}" }
    let(:expires_in)  { 42 }

    it 'passes the expires_in value to the cache' do
      expect(services.cache).to receive(:fetch).with('Steam-consume-d1249cd56af82e108d383f981ad953347dbb94dc', { expires_in: 42 }).and_return('Locomotive rocks!')
      is_expected.to eq 'Locomotive rocks!'
    end

    describe 'expires_in set to 0 (so basically, meaning non cache at all)' do

      let(:expires_in)  { 0 }

      it "doesn't pass the expires_in value to the cache" do
        expect(services.cache).to receive(:fetch).with('Steam-consume-d1249cd56af82e108d383f981ad953347dbb94dc', { force: true }).and_return('Locomotive rocks!')
        is_expected.to eq 'Locomotive rocks!'
      end

    end

  end

  describe 'timeout' do

    let(:response)  { { 'title' => 'first response' } }
    let(:url)       { 'http://blog.locomotiveapp.org/api/read' }
    let(:source)    { %{{% consume blog from "#{url}" timeout: 5.0 %}{{ blog.title }}{% endconsume %}} }

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
