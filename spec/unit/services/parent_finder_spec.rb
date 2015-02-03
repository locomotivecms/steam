require 'spec_helper'

describe Locomotive::Steam::Services::ParentFinder do

  let(:service)     { Locomotive::Steam::Services::ParentFinder.new(nil) }
  let(:repository)  { service.repository }

  describe '#find' do

    let(:name)          { '' }
    let(:another_page)  { instance_double('Index', title: 'Index') }
    let(:page)          { instance_double('AboutUs', title: 'About us') }

    subject { service.find(page, name) }

    it { is_expected.to eq nil }

    describe 'using the parent keyword' do

      let(:name) { 'parent' }

      before { expect(repository).to receive(:parent_of).and_return(another_page) }

      it { is_expected.to eq another_page }

    end

    describe 'using the fullpath' do

      let(:name) { 'index' }

      before { expect(repository).to receive(:by_fullpath).with('index').and_return(another_page) }

      it { is_expected.to eq another_page }

    end

  end

end
