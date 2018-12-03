require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Params do

  let(:params)    { { 'foo' => '42' } }
  let(:drop)      { described_class.new(params) }

  it { expect(drop.before_method('bar').to_s).to eq '' }

  it { expect(drop.before_method('foo').to_s).to eq '42' }

  describe 'prevent XSS attack' do

    context 'passing data from Liquid to HTML' do

      let(:params) { { 'foo' => 'Hello<script>alert(document.cookie)</script>' } }

      it { expect(drop.before_method('foo').to_s).to eq 'Hello&lt;script&gt;alert(document.cookie)&lt;/script&gt;' }

      context 'security is disabled' do

        it { expect(drop.before_method('foo').html_safe).to eq 'Hello<script>alert(document.cookie)</script>' }

      end

    end

    context 'passing data from Liquid to Javascript' do

      let(:params) { { 'foo' => "'+alert(document.cookie)+'" } }

      it { expect(drop.before_method('foo').to_s).to eq '&#39;+alert(document.cookie)+&#39;' }

    end

  end

end
