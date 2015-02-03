require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::SessionAssign do

  let(:source)    { '{% session_assign title=42 %}' }
  let(:session)   { Hash.new }
  let(:request)   { instance_double('Request', session: session) }
  let(:assigns)   { {} }
  let(:context)   { ::Liquid::Context.new(assigns, {}, { request: request }) }

  let!(:output)    { render_template(source, context) }

  subject { session[:title] }

  it { expect(output).to eq '' }

  describe 'store the object in the session' do

    it { is_expected.to eq 42 }

    describe 'the object is a string' do

      let(:source) { '{% session_assign title = "Hello world" %}' }
      it { is_expected.to eq 'Hello world' }

    end

    describe 'the object is a variable' do

      let(:assigns) { { 'product' => { 'name' => 'Snow!' } } }
      let(:source)  { '{% session_assign title = product.name %}' }
      it { is_expected.to eq 'Snow!' }

    end

  end

end
