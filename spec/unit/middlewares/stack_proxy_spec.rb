require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/stack_proxy'

describe Locomotive::Steam::Middlewares::StackProxy do

  let(:klass) { Locomotive::Steam::Middlewares::StackProxy }
  let(:proxy) { klass.new }

  describe '#initialize' do

    let(:args) { DefaultMiddleware }
    subject do
      klass.new { use(DefaultMiddleware) }
    end

    it 'adds it to the list' do
      expect(subject.list.size).to eq 1
      expect(subject.list.first).to eq [DefaultMiddleware]
    end

  end

  describe '#use' do

    let(:args) { DefaultMiddleware }
    before { proxy.use(*args) }

    it 'adds it to the operations' do
      expect(proxy.list.size).to eq 1
      expect(proxy.list.first).to eq [DefaultMiddleware]
    end

  end

  describe 'manipulating middlewares' do

    before do
      proxy.use DefaultMiddleware
      proxy.use SimpleMiddleware

      proxy.insert_before SimpleMiddleware, FooMiddleware
      proxy.use BarMiddleware, { answer: 42 }
      proxy.delete SimpleMiddleware
      proxy.insert_after 1, FancyMiddleware
    end

    subject { proxy.list }

    it do
      is_expected.to eq([
        [DefaultMiddleware],
        [FooMiddleware],
        [FancyMiddleware],
        [BarMiddleware, { answer: 42 }]
      ])
    end

  end

  class SimpleMiddleware; end
  class DefaultMiddleware; end
  class FooMiddleware; end
  class BarMiddleware; end
  class FancyMiddleware; end

end
