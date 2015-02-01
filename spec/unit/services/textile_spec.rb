require 'spec_helper'

describe Locomotive::Steam::Services::Textile do

  let(:service) { Locomotive::Steam::Services::Textile.new }

  describe '#to_html' do

    let(:text) { <<-EOF
h1. Give RedCloth a try!

A *simple* paragraph
    EOF
    }

    subject { service.to_html(text) }

    it do
      is_expected.to eq <<-EOF
<h1>Give RedCloth a try!</h1>
<p>A <strong>simple</strong> paragraph</p>
EOF
      .strip
    end

    describe 'no text' do

      let(:text) { nil }
      it { is_expected.to eq '' }
    end

  end

end
