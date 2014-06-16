require 'spec_helper'

describe 'Locomotive::Steam::Entities::Page' do

  it 'builds an empty page' do
    build_page.should_not be_nil
  end

  describe '#index?' do
    it { build_page(fullpath: {en: 'index'}).should be_index }
    it { build_page(fullpath: {en: 'about'}).should_not be_index }
    it { build_page(fullpath: {en: 'products/index'}).should_not be_index }
  end

  describe '#index_or_404?' do
    it { build_page(fullpath: {en: 'index'}).should be_index_or_404 }
    it { build_page(fullpath: {en: 'about'}).should_not be_index_or_404 }
    it { build_page(fullpath: {en: 'products/index'}).should_not be_index_or_404 }
    it { build_page(fullpath: {en: 'products/404'}).should_not be_index_or_404 }
    it { build_page(fullpath: {en: '404'}).should be_index_or_404 }
  end

  describe '#depth' do
    it { build_page(fullpath: {en: 'index'}).depth.should eq 0 }
    it { build_page(fullpath: {en: '404'}).depth.should eq 0 }
    it { build_page(fullpath: {en: 'about'}).depth.should eq 1 }
    it { build_page(fullpath: {en: 'about/me'}).depth.should eq 2 }
    it { build_page(fullpath: {en: 'about/index'}).depth.should eq 2 }
    it { build_page(fullpath: {en: 'about/the/team'}).depth.should eq 3 }
  end

  describe '#fullpath=', pending: true do
    context 'when the page has no slug yet' do
      it 'also sets the slug' do
        build_page(fullpath: 'this/is/the/page_full_path').slug.should eq 'page_full_path'
      end
    end

    context 'when the slug is already set' do
      it 'keeps the original slug', pending: true do
        build_page(fullpath: 'this/is/the/page_full_path', slug: 'the_slug').slug.should eq 'the_slug'
      end
    end
  end

  describe '#safe_fullpath', pending: true do
    let(:index_page) { build_page(fullpath: 'index') }
    let(:not_found_page) { build_page(fullpath: '404') }
    let(:about_page) { build_page(fullpath: 'about_me', parent: index_page) }
    let(:products_page) { build_page(fullpath: 'products', parent: index_page, templatized: true) }

    context 'not templatized' do
      context 'index or 404' do
        it { index_page.safe_fullpath.should eq 'index' }
        it { not_found_page.safe_fullpath.should eq '404' }
      end

      context 'other' do
        it { about_page.safe_fullpath.should eq 'about-me' }
      end
    end

    context 'templatized' do
      subject { build_page(fullpath: 'products', parent: index_page, templatized: true) }
      its(:safe_fullpath) { should eq '*' }
    end

    context 'templatized with not templatized parent' do
      subject { build_page(fullpath: 'about_me/contact', parent: about_page, templatized: true) }
      its(:safe_fullpath) { should eq 'about-me/*' }
    end

    context 'templatized parent' do
      subject { build_page(fullpath: 'products/detail', parent: products_page) }
      its(:safe_fullpath) { should eq '*/detail' }
    end
  end

  def build_page(attributes = {})
    Locomotive::Steam::Entities::Page.new(attributes)
  end

end
