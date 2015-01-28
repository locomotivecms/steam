require 'spec_helper'

describe 'Locomotive::Steam::Decorators::PageDecorator' do

  before { skip }

  let(:locale) { :en }

  it 'builds an empty decorator' do
    build_page.should_not be_nil
  end

  describe '#safe_fullpath' do
    let(:index_page)     { build_page(fullpath: { en: 'index'   }) }
    let(:not_found_page) { build_page(fullpath: { en: '404'     }) }
    let(:about_page)     { build_page(fullpath: { en: 'about_me'}, parent: index_page) }
    let(:products_page)  { build_page(fullpath: { en: 'products'}, parent: index_page, templatized: true) }

    context 'not templatized' do
      context 'index or 404' do
        it { decorated(index_page).safe_fullpath.should eq 'index' }
        it { decorated(not_found_page).safe_fullpath.should eq '404' }
      end

      context 'other' do
        it { decorated(about_page).safe_fullpath.should eq 'about-me' }
      end
    end

    context 'templatized' do
      subject { decorated build_page(fullpath: { en: 'products' }, parent: index_page, templatized: true) }
      # its(:safe_fullpath) { should eq '*' }
    end

    context 'templatized with not templatized parent' do
      subject { decorated build_page(fullpath: { en: 'about_me/contact' }, parent: about_page, templatized: true) }
      # its(:safe_fullpath) { should eq 'about-me/*' }
    end

    context 'templatized parent' do
      subject { decorated build_page(fullpath: { en: 'products/detail' }, parent: products_page) }
      # its(:safe_fullpath) { should eq '*/detail' }
    end
  end

  def decorated(page)
    Locomotive::Steam::Decorators::PageDecorator.new(
      Locomotive::Decorators::I18nDecorator.new(
        page, locale
      )
    )
  end

  def build_page(attributes = {})
    Locomotive::Steam::Entities::Page.new(attributes)
  end

end
