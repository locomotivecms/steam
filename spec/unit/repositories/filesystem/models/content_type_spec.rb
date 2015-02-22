# require 'spec_helper'

# describe Locomotive::Steam::Repositories::Filesystem::Models::ContentType do

#   let(:fields) { [instance_double('Field1', label: 'Title', name: :title, localized: false), instance_double('Field2', label: 'Author', name: :author, localized: true)] }
#   let(:content_type)  do
#     Locomotive::Steam::Repositories::Filesystem::Models::ContentType.new(name: 'Articles').tap do |type|
#       type.fields = fields
#     end
#   end

#   describe '#label_field_name' do

#     subject { content_type.label_field_name }
#     it { is_expected.to eq :title }

#     context 'defined within the content type itself' do

#       before { allow(content_type.attributes).to receive(:[]).with(:label_field_name).and_return('author') }
#       it { is_expected.to eq :author }

#     end

#   end

#   describe '#localized_fields_names' do

#     subject { content_type.localized_fields_names }
#     it { is_expected.to eq [:author] }

#   end

#   describe '#order_by' do

#     subject { content_type.order_by }
#     it { is_expected.to eq '_position asc' }

#     context 'specifying manually' do

#       before do
#         content_type.attributes[:order_by] = 'manually'
#         content_type.attributes[:order_direction] = 'desc'
#       end
#       it { is_expected.to eq '_position desc' }

#     end

#   end

# end
