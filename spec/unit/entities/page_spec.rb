require 'spec_helper'

describe 'Locomotive::Steam::Entities::Page', focused: true do

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

  describe '#fullpath=' do
    context 'when the page has no slug yet' do
      it 'also sets the slug' do
        build_page(fullpath: {en: 'this/is/the/page_full_path'}).slug[:en].should eq 'page_full_path'
      end
    end

    context 'when the slug is already set' do
      it 'keeps the original slug' do
        build_page(fullpath: {en: 'this/is/the/page_full_path'}, slug: {en: 'the_slug'}).slug[:en].should eq 'the_slug'
      end
    end
  end

  def build_page(attributes = {})
    Locomotive::Steam::Entities::Page.new(attributes)
  end

end
