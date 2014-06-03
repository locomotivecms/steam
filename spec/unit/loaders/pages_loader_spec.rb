require 'spec_helper'

describe Locomotive::Steam::Loader::Yml::PagesLoader do


  let(:path) { default_fixture_site_path }
  subject { Locomotive::Steam::Loader::Yml::PagesLoader.new path, mapper }
  it { should be_kind_of Object }
end
