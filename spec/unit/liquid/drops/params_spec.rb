require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Params do

  let(:params)    { { 'foo' => '42' } }
  let(:drop)      { described_class.new(params) }

  it { expect(drop.liquid_method_missing('bar').to_s).to eq '' }

  it { expect(drop.liquid_method_missing('foo').to_s).to eq '42' }

  describe 'prevent XSS attack' do

    context 'passing data from Liquid to HTML' do

      let(:params) { { 'foo' => 'Hello<script>alert(document.cookie)</script>' } }

      it { expect(drop.liquid_method_missing('foo').to_s).to eq 'Hello&lt;script&gt;alert(document.cookie)&lt;/script&gt;' }

      context 'security is disabled' do

        it { expect(drop.liquid_method_missing('foo').html_safe).to eq 'Hello<script>alert(document.cookie)</script>' }

      end

    end

    context 'passing data from Liquid to Javascript' do

      let(:params) { { 'foo' => "'+alert(document.cookie)+'" } }

      it { expect(drop.liquid_method_missing('foo').to_s).to eq '&#39;+alert(document.cookie)+&#39;' }

    end

  end

  describe 'gives access to the Hash object through the unsafe method' do

    let(:params) { { 'foo' => 'hello', 'bar' => 'world' } }

    it 'expects to respond to []' do
      expect(drop.unsafe['foo']).to eq('hello')
    end

    it 'expects to respond to each_pair' do
      memo = []
      drop.unsafe.each_pair { |p| memo << p.last }
      expect(memo.join(' ')).to eq 'hello world'
    end

  end

end
