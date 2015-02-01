require 'spec_helper'

describe Locomotive::Steam::Services::Markdown do

  let(:service) { Locomotive::Steam::Services::Markdown.new }

  describe '#to_html' do

    let(:text) { <<-EOF
First level header
==================

Second level header
-------------------
    EOF
    }

    subject { service.to_html(text) }

    it do
      is_expected.to eq <<-EOF
<h1>First level header</h1>

<h2>Second level header</h2>
      EOF
    end

    describe 'no text' do

      let(:text) { nil }
      it { is_expected.to eq '' }
    end

  end

end
