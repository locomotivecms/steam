# require 'spec_helper'

# describe Locomotive::Steam::Repositories::Filesystem::ContentType do

#   let(:fields)  { [{ title: { hint: 'Title of the article', type: 'string' } }, { author: { type: 'string', label: 'Fullname of the author' } }] }
#   let(:loader)  { instance_double('Loader', list_of_attributes: [{ slug: 'articles', name: 'Articles', fields: fields }]) }
#   let(:site)    { instance_double('Site', default_locale: :en, locales: [:en, :fr]) }
#   let(:locale)  { :en }

#   let(:repository) { Locomotive::Steam::Repositories::Filesystem::ContentType.new(loader, site, locale) }

#   describe '#collection' do

#     subject { repository.send(:collection).first }

#     it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::ContentType }

#     it 'applies the sanitizer' do
#       expect(subject.name).to eq('Articles')
#       expect(subject.slug).to eq('articles')
#       expect(subject.fields.size).to eq 2
#       expect(subject.fields_by_name.size).to eq 2
#     end

#     describe 'a field of the first element' do

#       subject { repository.send(:collection).first.fields.first }

#       it { expect(subject.class).to eq Locomotive::Steam::Repositories::Filesystem::Models::ContentTypeField }

#       it 'has properties' do
#         expect(subject.name).to eq :title
#         expect(subject.label).to eq 'Title'
#         expect(subject.hint).to eq 'Title of the article'
#         expect(subject.type).to eq :string
#       end

#     end

#   end

#   describe '#by_slug' do

#     let(:slug) { nil }
#     subject { repository.by_slug(slug) }

#     it { is_expected.to eq nil }

#     context 'existing content type' do

#       let(:slug) { 'articles' }
#       it { expect(subject.name).to eq 'Articles' }

#     end

#     context 'slug is already a content type' do

#       let(:slug) { instance_double('ContentType') }
#       it { is_expected.to eq slug }

#     end

#   end

#   describe '#fields_for' do

#     let(:type) { nil }
#     subject { repository.fields_for(type) }

#     it { is_expected.to eq nil }

#     context 'with fields' do

#       let(:type) { instance_double('ContentType', fields: [true]) }
#       it { is_expected.to eq([true]) }

#     end

#   end

#   describe '#look_for_unique_fields' do

#     let(:type) { nil }
#     subject { repository.look_for_unique_fields(type) }

#     it { is_expected.to eq nil }

#     context 'with fields' do

#       let(:field) { instance_double('Field', name: :title) }
#       let(:type)  { instance_double('ContentType', query_fields: [field])}

#       it { expect(subject).to eq(title: field) }

#     end

#   end

#   describe '#select_options' do

#     let(:type)  { repository.by_slug('articles') }
#     let(:name)  { nil }
#     subject { repository.select_options(type, name) }

#     it { is_expected.to eq nil }

#     context 'a select field' do

#       let(:fields) do
#         [
#           { title: { hint: 'Title of the article', type: 'string' } },
#           { category: { type: 'select', select_options: { en: ['cooking', 'bread'], fr: ['cuisine', 'pain'] } } }
#         ]
#       end

#       let(:name) { :category }
#       it { is_expected.to eq %w(cooking bread) }

#       context 'not a select field' do

#         let(:name) { :title }
#         it { is_expected.to eq nil }

#       end

#     end

#   end

# end
