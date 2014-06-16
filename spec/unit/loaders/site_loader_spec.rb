require 'spec_helper'

describe Locomotive::Steam::Loader::Yml::SiteLoader, focused: true do

  let(:path) { default_fixture_site_path }
  let(:loader) { Locomotive::Steam::Loader::Yml::SiteLoader.new path, mapper }

  before { loader.load! }

  subject { Locomotive::Models[:sites].all.first }

  it { should be_kind_of Locomotive::Steam::Entities::Site }
  its(:name) { should eql 'Sample website' }
  its(:domains) { should eql ['example.org', 'sample.example.com', '0.0.0.0'] }
  context 'localized fields' do
    it do
      subject.seo_title[:en].should eq 'A simple LocomotiveCMS website'
      subject.seo_title[:fr].should eq 'Un simple LocomotiveCMS site web'
    end
  end
end
