require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Translate do

  include Locomotive::Steam::Liquid::Filters::Translate

  let(:services)      { Locomotive::Steam::Services.build_instance }
  let(:translator)    { services.translator }
  let(:context)       { instance_double('Context', registers: { services: services }) }

  before { @context = context }

  describe '#translate' do

    before { allow(translator).to receive(:translate).and_return(translation) }

    let(:input)       { 'example_text' }
    let(:translation) { 'Example text' }

    subject { translate(input) }

    it { is_expected.to eq 'Example text' }

    describe 'no translation found, displays the key itself' do

      let(:translation) { nil }
      it { is_expected.to eq 'example_text' }

    end

  end

end
