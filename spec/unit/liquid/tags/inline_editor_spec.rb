require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::InlineEditor do

  let(:source)  { "{% inline_editor %}" }

  subject { render_template(source) }

  it { is_expected.to eq '' }

end
