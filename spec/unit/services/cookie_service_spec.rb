require 'spec_helper'

describe Locomotive::Steam::CookieService do

  let(:steam_cookies)   { {} }
  let(:request_cookies) { {} }
  let(:request)         { instance_double('Request', env: { 'steam.cookies' => steam_cookies }, cookies: request_cookies) }
  let(:cookie)          { {'value' => 'bar2'} }
  let(:service)         { described_class.new(request) }

  describe '#get cookies from request' do

    let(:request_cookies) { {'foo' => 'bar'} }
    subject { service.get('foo') }

    context 'from request' do
      it { is_expected.to eq 'bar' }
    end

    context 'from response' do
      let(:steam_cookies) { {'foo' => {'value' => 'bar2'}} }
      it { is_expected.to eq 'bar2' }
    end

  end

  describe '#set cookies from response' do

    subject { service.set('foo', cookie) }

    it 'set the cookies into steam' do
      is_expected.to eq cookie
      expect(steam_cookies).to eq({'foo' => cookie})
    end

  end

end
