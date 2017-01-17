require 'spec_helper'

describe Locomotive::Steam::PageRedirectionService do

  let(:page_finder)   { instance_double('PageFinder') }
  let(:url_builder)   { instance_double('UrlBuilder') }
  let(:service)       { described_class.new(page_finder, url_builder) }

  describe '#redirect_to' do

    let(:page) { instance_double('Page') }

    subject { service.redirect_to('about-us') }

    context 'the page exists' do

      before { expect(page_finder).to receive(:by_handle).with('about-us').and_return(page) }

      it 'raises an PageRedirectionException that will caught the appropriate middleware' do
        expect(url_builder).to receive(:url_for).with(page, nil).and_return('/about-us')
        expect { subject }.to raise_exception(Locomotive::Steam::RedirectionException, 'Redirect to /about-us')
      end

      context 'passing a locale' do

        subject { service.redirect_to('about-us', 'fr') }

        it 'raises an PageRedirectionException that will caught the appropriate middleware' do
          expect(url_builder).to receive(:url_for).with(page, 'fr').and_return('/a-notre-sujet')
          expect { subject }.to raise_exception(Locomotive::Steam::RedirectionException, 'Redirect to /a-notre-sujet')
        end

      end

    end

    context "the page doesn't exist" do

      before { expect(page_finder).to receive(:by_handle).with('about-us').and_return(nil) }

      it "returns false and doesn't raise a redirection exception" do
        is_expected.to eq false
      end

    end

  end

end
