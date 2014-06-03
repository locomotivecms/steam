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
  end

end
