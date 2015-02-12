require 'spec_helper'

describe Locomotive::Steam::Repositories::Filesystem::MemoryAdapter::Condition do

  let(:entry)    { instance_double('Site', { title: { en: 'Awesome Site' }, content: 'foo' }) }
  let(:locale)   { :en }
  let(:field)    { :title }
  let(:operator) { :eq }
  let(:name)     { "#{field}.#{operator}"}
  let(:value)    { 'Awesome Site' }

  subject { Locomotive::Steam::Repositories::Filesystem::MemoryAdapter::Condition.new(name, value, locale) }

  describe '#entry_value' do
    context 'i18n' do
      let(:name)  { 'title.eq' }
      let(:value) { 'Awesome Site' }

      context 'single entry' do
        specify('should be match') do
          expect(subject.matches?(entry)).to eq true
        end

        specify('return value') do
          expect(subject.send(:entry_value, entry)).to eq(value)
        end
      end
    end
    context 'regular way' do
      let(:name)  { 'content.eq' }
      let(:value) { 'foo' }

      context 'single entry' do
        specify('should be match') do
          expect(subject.matches?(entry)).to eq true
        end

        specify('return value') do
          expect(subject.send(:entry_value, entry)).to eq(value)
        end
      end
    end
  end

  describe '#decode_operator_and_field!' do
    before { subject.send(:decode_operator_and_field!) }

    context 'with normal value' do
      specify('name should be left part of dot') { expect(subject.field).to eq(field) }
      specify('operator should be right part of dot') { expect(subject.operator).to eq(operator) }
      specify('right_operand should be value') { expect(subject.value).to eq(value) }
    end

    context 'with regex value' do
      let(:value) { /^[a-z]$/ }
      specify('operator should be matchtes') { expect(subject.operator).to eq(:matches) }
    end
  end

  describe '#decode_operator_and_field!' do
    context 'with unsupported operator' do
      let(:name) { 'domains.unsupported' }
      specify('should be throw Exception') do
        expect do
          subject.send(:decode_operator_and_field!)
        end.to raise_error Locomotive::Steam::Repositories::Filesystem::MemoryAdapter::Condition::UnsupportedOperator
      end
    end
  end

  describe '#adapt_operator!' do
    let(:name) { 'domains.==' }
    before do
      subject.send(:decode_operator_and_field!)
      subject.send(:adapt_operator!, value)
    end
    context 'with single value' do
      let(:value) { 'sample.example.com' }
      specify('operator should be :==') { expect(subject.operator).to eq(:==) }
    end
    context 'with array of values' do
      let(:value) { ['sample.example.com'] }
      specify('operator should be :in') { expect(subject.operator).to eq(:in) }
    end
  end

  describe '#array_contains?' do
    let(:source) { [1, 2, 3, 4] }
    let(:target) { [1, 2, 3] }
    context 'with target contains in source' do
      specify('should be true') do
        expect(subject.send(:array_contains?, source, target)).to eq true
      end
    end
  end

  describe '#value_in_right_operand?' do
    context 'value contains in right operand' do
      let(:value) { [1, 2, 3, 4] }
      let(:right_operand) { [1, 2, 3] }

      before do
        allow(subject).to receive(:operator).and_return(operator)
        allow(subject).to receive(:right_operand).and_return(right_operand)
      end

      context 'with operator :in' do
        let(:operator) { :in }
        specify('should return true') do
          expect(subject.send(:value_is_in_entry_value?, value)).to eq true
        end
      end

      context 'with other operator' do
        let(:operator) { :nin }
        specify('should not return true') do
          expect(subject.send(:value_is_in_entry_value?, value)).to eq false
        end
      end
    end
  end
end
