require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Json do

  include Locomotive::Steam::Liquid::Filters::Json

  let(:input) { nil }
  subject     { json(*input) }

  describe 'adds quotes to a string' do

    let(:input) { 'foo' }
    it { expect(subject).to eq %("foo") }

  end

  context 'drop' do

    describe 'includes only the fields specified' do

      let(:input) { [Liquid::TestDrop.new(title: 'Acme', body: 'Lorem ipsum'), 'title'] }
      it { expect(subject).to eq %({"title":"Acme"}) }

    end

  end

  context 'collections' do

    describe 'adds brackets and quotes to a collection' do

      let(:input) { [['foo', 'bar']] }
      it { expect(subject).to eq %(["foo","bar"]) }

    end

    describe 'includes the first field' do

      let(:input) {
        [[Liquid::TestDrop.new(title: 'Acme', body: 'Lorem ipsum'),
          Liquid::TestDrop.new(title: 'Hello world', body: 'Lorem ipsum')], 'title'] }
      it { expect(subject).to eq %(["Acme","Hello world"]) }

    end

    describe 'includes the specified fields' do

      let(:input) {
        [[Liquid::TestDrop.new(title: 'Acme', body: 'Lorem ipsum', date: '2013-12-13'),
          Liquid::TestDrop.new(title: 'Hello world', body: 'Lorem ipsum', date: '2013-12-12')], 'title, body'] }
      it { expect(subject).to eq %([{"title":"Acme","body":"Lorem ipsum"},{"title":"Hello world","body":"Lorem ipsum"}]) }

    end

  end

  describe '#open_json' do

    let(:input) { '' }
    subject     { open_json(input) }

    it { expect(subject).to eq '' }

    context 'without leading and trailing brackets' do

      let(:input) { %(["foo",[1,2],"bar"]) }
      it { expect(subject).to eq %("foo",[1,2],"bar") }

    end

    context 'without leading and trailing braces' do

      let(:input) { %({"title":"Acme","body":"Lorem ipsum"}) }
      it { expect(subject).to eq %("title":"Acme","body":"Lorem ipsum") }

    end

  end

end
