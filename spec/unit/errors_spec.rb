require 'spec_helper'

describe Locomotive::Steam::TemplateError do

  let(:message)   { 'Wrong syntax' }
  let(:file)      { 'template.liquid.haml' }
  let(:source)    { %w(a b c d e f g h i j k l m n o p q r s t u v w y z).join("\n") }
  let(:line)      { 10 }
  let(:backtrace) { 'Backtrace' }
  let(:error)     { described_class.new(message, file, source, line, backtrace) }

  describe '#code_lines' do

    subject { error.code_lines }

    it { is_expected.to eq [[5, 'e'], [6, 'f'], [7, 'g'], [8, 'h'], [9, 'i'], [10, 'j'], [11, 'k'], [12, 'l'], [13, 'm'], [14, 'n'], [15, 'o']] }

  end

  describe '#backtrace' do

    subject { error.original_backtrace }

    it { is_expected.to eq 'Backtrace' }

  end

end
