require 'spec_helper'

describe "#locales" do

  Dir.glob('config/locales/**/*.yml').each do |locale_file|
    describe "#{locale_file}" do
      it_behaves_like 'my valid locale file' do
        let(:locale_file) { locale_file }
      end
    end

    unless locale_file == 'config/locales/en.yml'
      describe "#{locale_file}", pending: 'need to be fixed' do
        it_behaves_like 'complete translation of' do
          let(:locale_target) { locale_file }
        end
      end
    end

  end

end
