shared_examples_for 'complete translation of' do
  let(:locale_source) { 'config/locales/en.yml' }
  let(:locale_target) { 'config/locales/fr.yml' }

  subject { locale_source }

  it { should be_a_complete_translation_of locale_target }
end
