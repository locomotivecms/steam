require 'spec_helper'

describe Locomotive::Steam::Loader::Yml::PagesLoader do


  let(:path) { default_fixture_site_path }
  let(:loader) { Locomotive::Steam::Loader::Yml::PagesLoader.new path, mapper }
  subject { loader }
  before { Locomotive::Models[:pages].current_locale = :en }

  describe '#initialize' do
    it { should be_kind_of Object }
  end

  describe '#load!', pending: true  do
    before { loader.load! }
    it 'loads pages in the pages Repository' do
      Locomotive::Models[:pages].all.size.should > 0
    end

    it 'creates only one Entity for all locales' do
      # TODO do not rely on repository

      Locomotive::Models[:pages].matching_paths(['index']).all.size.should eq 1
    end

    context 'records content' do
      subject { Locomotive::Models[:pages]['index'] }
      it { subject.title[:en].should eql 'Home page' }
      it { subject.title[:fr].should eql 'Page d\'accueil' }
    end
  end
end
