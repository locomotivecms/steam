require 'spec_helper'

describe Locomotive::Steam::RenderError do

  let(:message)   { 'Wrong syntax' }
  let(:file)      { 'template.liquid.haml' }
  let(:source)    { %w(a b c d e f g h i j k l m n o p q r s t u v w y z).join("\n") }
  let(:line)      { 10 }
  let(:backtrace) { 'Backtrace' }
  let(:error)     { described_class.new(message, file, source, line, backtrace) }

  describe '#code_lines' do

    subject { error.code_lines }

    it { is_expected.to eq [[5, 'f'], [6, 'g'], [7, 'h'], [8, 'i'], [9, 'j'], [10, 'k'], [11, 'l'], [12, 'm'], [13, 'n'], [14, 'o'], [15, 'p']] }

  end

  describe '#backtrace' do

    subject { error.original_backtrace }

    it { is_expected.to eq 'Backtrace' }

  end

end
