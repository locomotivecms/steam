require 'spec_helper'

describe Locomotive::Steam::ParentFinderService do

  let(:site)        { instance_double('Site', default_locale: :en) }
  let(:repository)  { instance_double('PageRepository', site: site, locale: :en)}
  let(:service)     { described_class.new(repository) }

  describe '#find' do

    let(:name)          { '' }
    let(:another_page)  { instance_double('Index', title: 'Index', attributes: {}) }
    let(:page)          { instance_double('AboutUs', title: 'About us') }

    subject { service.find(page, name).try(:title) }

    it { is_expected.to eq nil }

    describe 'using the parent keyword' do

      let(:name) { 'parent' }

      before { expect(repository).to receive(:parent_of).and_return(another_page) }

      it { is_expected.to eq 'Index' }

    end

    describe 'using the fullpath' do

      let(:name) { 'index' }

      before { expect(repository).to receive(:by_fullpath).with('index').and_return(another_page) }

      it { is_expected.to eq 'Index' }

    end

  end

end
