require 'spec_helper'

describe Locomotive::Steam::Utils::YAMLFrontMattersTemplate do

let(:regular_content) do
  <<YAMLRAW
%p Content
YAMLRAW
  end

let(:attributes_content) do
  <<YAMLRAW
---
data: value 1
other: value 2
---
%p Content
YAMLRAW
  end

  subject { Locomotive::Steam::Utils::YAMLFrontMattersTemplate.new('dummy_path.haml') }
  before { subject.stub(data: content) }

  context 'regular data' do
    let(:content)     { regular_content }
    its(:source)      { should eql "<p>Content</p>\n" }
    its(:line_offset) { should eql 0 }
    its(:attributes)  { should eql({}) }
  end

  context 'data with attributes' do
    let(:content)     { attributes_content }
    its(:source)      { should eql "<p>Content</p>\n" }
    its(:line_offset) { should eql 4 }
    its(:attributes)  { should eql 'data' => 'value 1', 'other' => 'value 2' }
  end


end
