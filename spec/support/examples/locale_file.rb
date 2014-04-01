shared_examples_for 'my valid locale file' do
  let(:local_file) { 'config/locales/app/en.yml' }

  subject { locale_file }

  it { should be_parseable }
  it { should have_a_valid_locale }

  # it { should have_valid_pluralization_keys }
  # it { should_not have_missing_pluralization_keys }
  # it { should have_one_top_level_namespace }
  # it { should be_named_like_top_level_namespace }
  # it { should_not have_legacy_interpolations }
end