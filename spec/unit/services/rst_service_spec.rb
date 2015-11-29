require 'spec_helper'

describe Locomotive::Steam::RstService do

  let(:service) { described_class.new }

  describe '#to_html' do

    let(:text) { <<-EOF
Hello world!
============
Lorem ipsum
    EOF
    }

    subject { service.to_html(text) }

    it do
      is_expected.to eq <<-EOF
<h1 class="title">Hello world!</h1>
<p>Lorem ipsum</p>

      EOF
    end

    describe 'no text' do

      let(:text) { nil }
      it { is_expected.to eq '' }
    end

  end

end
