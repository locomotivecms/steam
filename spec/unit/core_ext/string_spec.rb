require 'spec_helper'

describe String do

  describe '#permalink!' do

    let(:string) { 'foo bar' }

    before { string.permalink! }

    it { expect(string).to eq 'foo-bar' }

  end

  describe '#to_bool' do

    subject { string.to_bool }

    describe 'true values' do

      %w(true t yes y 1).each do |val|
        let(:string) { val }
        it { is_expected.to eq true }
      end

    end

    describe 'false values' do

      (%w(false f no n 0) + ['']).each do |val|
        let(:string) { val }
        it { is_expected.to eq false }
      end

    end

    describe 'no truthy or falsy' do
      let(:string) { 'foo' }
      it { expect { subject }.to raise_error(%(invalid value for Boolean: "foo")) }
    end

  end

end
