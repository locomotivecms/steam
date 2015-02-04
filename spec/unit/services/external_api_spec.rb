require 'spec_helper'

describe Locomotive::Steam::Services::ExternalAPI do

  let(:service) { Locomotive::Steam::Services::ExternalAPI.new }

  describe '#consume' do

    let(:url)             { '' }
    let(:options)         { {} }
    let(:code)            { 200 }
    let(:parsed_response) { Hash.new }
    let(:response)        { instance_double('Response', code: code, parsed_response: parsed_response) }

    subject { service.consume(url, options) }

    describe 'sets the base uri from a simple url' do

      let(:url) { 'http://blog.locomotiveapp.org' }
      it do
        expect(service.class).to receive(:get).with('/', { base_uri: 'http://blog.locomotiveapp.org' }).and_return(response)
        subject
      end

      describe 'wrong response (<> 200)' do

        let(:code) { 500 }
        it do
          expect(service.class).to receive(:get).with('/', { base_uri: 'http://blog.locomotiveapp.org' }).and_return(response)
          expect(subject).to eq nil
        end

      end

      describe 'returns a collection instead of a hash' do

        let(:parsed_response) { [{ 'averagePrice' => 1 }] }
        it do
          expect(service.class).to receive(:get).with('/', { base_uri: 'http://blog.locomotiveapp.org' }).and_return(response)
          expect(subject.first['average_price']).to eq 1
        end

      end

    end

    describe 'sets the base uri from a much more complex url' do

      let(:url) { 'http://free.worldweatheronline.com/feed/weather.ashx?key=secretapikey&format=json' }
      it do
        expect(service.class).to receive(:get).with('/feed/weather.ashx?key=secretapikey&format=json', { base_uri: 'http://free.worldweatheronline.com' }).and_return(response)
        subject
      end

    end


    describe 'sets both the base uri and the path from an url with parameters' do

      let(:url) { 'http://blog.locomotiveapp.org/api/read/json?num=3' }
      it do
        expect(service.class).to receive(:get).with('/api/read/json?num=3', { base_uri: 'http://blog.locomotiveapp.org' }).and_return(response)
        subject
      end

    end

    describe 'sets auth credentials' do

      let(:url)     { 'http://blog.locomotiveapp.org' }
      let(:options) { { username: 'john', password: 'foo' } }
      it do
        expect(service.class).to receive(:get).with('/', { base_uri: 'http://blog.locomotiveapp.org', basic_auth: { username: 'john', password: 'foo' } }).and_return(response)
        subject
      end
    end

  end

end
