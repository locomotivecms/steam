require 'spec_helper'

describe Locomotive::Steam::UrlFinderService do

  let(:url_builder)           { instance_double('UrlBuilder') }
  let(:page_finder)           { instance_double('PageFinder') }
  let(:content_entry_finder)  { instance_double('ContentEntryFinder') }
  let(:service) { described_class.new(url_builder, page_finder, content_entry_finder) }

  describe '#url_for' do

    subject { service.url_for(value) }

    context 'value is an url' do

      let(:value) { 'https://www.locomotivecms.com' }
      it { is_expected.to eq(['https://www.locomotivecms.com', false]) }

    end

    context 'value is a link to an external site' do

      let(:value) { { 'type' => '_external', 'value' => 'https://www.locomotivecms.com', 'new_window' => true } }
      it { is_expected.to eq(['https://www.locomotivecms.com', true]) }

    end

    context 'value is an email address' do

      let(:value) { { 'type' => 'email', 'value' => 'jane@doe.net', 'new_window' => false } }
      it { is_expected.to eq(['mailto:jane@doe.net', false]) }

    end

    context 'value is a link to a page' do

      let(:page)  { instance_double('Page', not_found?: false) }
      let(:value) { { 'type' => 'page', 'value' => 42, 'new_window' => true, 'anchor' => '' } }

      context 'the page exists' do

        before do
          expect(page_finder).to receive(:find_by_id).with(42).and_return(page)
          expect(url_builder).to receive(:url_for).with(page).and_return('/')
        end

        it { is_expected.to eq(['/', true]) }

        context 'pointing to a section' do

          let(:value) { { 'type' => 'page', 'value' => 42, 'anchor' => 'getting-started' } }
          it { is_expected.to eq(['/#getting-started', false]) }

        end

      end

      context "the page doesn't exist" do

        before do
          expect(page_finder).to receive(:find_by_id).with(42).and_return(nil)
          expect(page_finder).to receive(:find).with('404').and_return(page)
          expect(url_builder).to receive(:url_for).with(page).and_return('/404')
        end

        it { is_expected.to eq(['/404', true]) }

      end

    end

    context 'value is a link to a content entry' do

      let(:entry) { instance_double('Product') }
      let(:page)  { instance_double('Page', :content_entry= => true, not_found?: false) }
      let(:value) { {
        'type' => 'content_entry',
        'value' => { 'page_id' => 42, 'content_type_slug' => 'products', 'id' => 1 },
        'new_window' => true
      } }

      before do
        expect(page_finder).to receive(:find_by_id).with(42).and_return(page)
        expect(content_entry_finder).to receive(:find).with('products', 1).and_return(entry)
        expect(url_builder).to receive(:url_for).with(page).and_return('/my-product')
      end

      it { is_expected.to eq(['/my-product', true]) }

    end

  end

  describe '#decode_url_for' do

    let(:value) { 'eyJ0eXBlIjoiX2V4dGVybmFsIiwidmFsdWUiOiJodHRwczovL3d3dy5ub2NvZmZlZS5mciIsImxhYmVsIjpbImV4dGVybmFsIiwiaHR0cHM6Ly93d3cubm9jb2ZmZWUuZnIiXX0=' }
    subject { service.decode_url_for(value) }

    it { is_expected.to eq(['https://www.nocoffee.fr', false]) }

  end

  describe '#decode_urls_for' do

    let(:value) { 'eyJ0eXBlIjoiX2V4dGVybmFsIiwidmFsdWUiOiJodHRwczovL3d3dy5ub2NvZmZlZS5mciIsImxhYmVsIjpbImV4dGVybmFsIiwiaHR0cHM6Ly93d3cubm9jb2ZmZWUuZnIiXX0=' }
    let(:text)  { %(<a href="//locomotive/_locomotive-link/#{value}">My Link</a>) }
    subject     { service.decode_urls_for(text) }

    it { is_expected.to eq('<a href="https://www.nocoffee.fr">My Link</a>') }

  end

end
