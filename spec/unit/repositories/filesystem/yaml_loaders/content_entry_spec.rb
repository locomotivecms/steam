# require 'spec_helper'

# describe Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::ContentEntry do

#   let(:root_path)       { default_fixture_site_path }
#   let(:cache)           { NoCacheStore.new }
#   let(:content_type)    { instance_double('Articles', slug: 'bands') }
#   let(:loader)          { Locomotive::Steam::Repositories::Filesystem::YAMLLoaders::ContentEntry.new(root_path, cache) }

#   describe '#list_of_attributes' do

#     subject { loader.list_of_attributes(content_type).sort { |a, b| a[:_label] <=> b[:_label] } }

#     it 'tests various stuff' do
#       expect(subject.size).to eq 3
#       expect(subject.first[:_label]).to eq 'Alice in Chains'
#       expect(subject.first[:content_type]).to eq content_type
#     end

#   end

# end
