require 'spec_helper'

describe Locomotive::Steam::Models::Scope do

  let(:site)    { instance_double('Site', _id: 1) }
  let(:locale)  { :en }
  let(:context) { nil }
  let(:scope)   { described_class.new(site, locale, context) }

  describe '#to_key' do

    subject { scope.to_key }

    it { is_expected.to eq 'site_1' }

    context 'with a content type for instance' do

      let(:content_type) { instance_double('ContentType', _id: 42) }
      let(:context) { { content_type: content_type } }

      it { is_expected.to eq 'site_1_content_type_42' }

    end

  end

end
