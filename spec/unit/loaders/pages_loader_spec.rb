require 'spec_helper'

describe Locomotive::Steam::Loader::Yml::PagesLoader do


  let(:path) { default_fixture_site_path }
  subject { Locomotive::Steam::Loader::Yml::PagesLoader.new path, mapper }

  describe '#initialize' do
    it { should be_kind_of Object }
  end

  describe '#load!' do
    before { subject.load! }
    it 'loads pages in the pages Repository' do
      Locomotive::Models[:pages].all(:en).size.should > 0
    end
    it 'creates only one Entity for all locales' do
      # TODO do not rely on repository
      Locomotive::Models[:pages].matching_paths(['index']).size.should eq 1
    end
  end
end
