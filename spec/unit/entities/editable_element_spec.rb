require 'spec_helper'

describe Locomotive::Steam::EditableElement do

  let(:attributes) { {} }
  let(:page) { described_class.new(attributes) }

  it { expect(page.block).to eq nil }

end
