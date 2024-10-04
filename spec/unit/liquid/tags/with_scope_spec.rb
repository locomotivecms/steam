require 'spec_helper'
require 'origin'

describe Locomotive::Steam::Liquid::Tags::WithScope do

  let(:assigns)     { {} }
  let(:context)     { ::Liquid::Context.new(assigns, {}, {}) }
  let(:output)      { render_template(source, context) }
  let(:conditions)  { context['conditions'] }

  describe 'no attributes' do

    let(:source)  { '{% with_scope %}42{% endwith_scope %}'}
    it { expect { output }.to raise_error("Liquid syntax error (line 1): Syntax Error in 'with_scope' - Valid syntax: with_scope <name_1>: <value_1>, ..., <name_n>: <value_n>") }

  end

  describe 'valid syntax' do

    before { output }

    describe 'renders basic stuff' do
      let(:source) { '{% with_scope a: 1 %}42{% endwith_scope %}' }
      it { expect(output).to eq '42' }
    end

    describe 'store the conditions in the context' do

      let(:source) { "{% with_scope active: true, price: 42, title: 'foo', hidden: false %}{% assign conditions = with_scope %}{% assign content_type = with_scope_content_type %}{% endwith_scope %}" }

      it { expect(context['conditions'].keys).to eq(%w(active price title hidden)) }
      it { expect(context['content_type']).to eq false }

    end

    describe 'pass directly a hash built with the Action liquid tag for example' do

      let(:assigns) { { 'my_filters' => { active: true, price: 42, title: "/like this/ix", hidden: false } } }

      let(:source)  { "{% with_scope my_filters %}{% assign conditions = with_scope %}{% assign content_type = with_scope_content_type %}{% endwith_scope %}" }

      it { expect(context['conditions'].keys).to eq(%w(active price title hidden)) }
      it { expect(conditions['active']).to eq true }
      it { expect(conditions['title']).to eq(/like this/ix) }

      context "the variable doesn't exist" do

        let(:assigns) { { } }
        it { expect(context['conditions']).to eq({}) }

      end

    end

    describe 'don\'t decode numeric operations' do
      let(:source) { "{% with_scope price: 41 + 1 %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['price']).to eq 41 }

      context 'the operation calls a variable' do
        let(:assigns) { { 'prices' => { 'low' => 41 } } }
        let(:source) { "{% with_scope price: prices.low + 1 %}{% assign conditions = with_scope %}{% endwith_scope %}" }
        it { expect(conditions['price']).to eq 41 }
      end
    end

    describe 'decode basic options (boolean, integer, ...)' do

      let(:source) { "{% with_scope active: true, price: 42, title: 'foo', hidden: false %}{% assign conditions = with_scope %}{% endwith_scope %}" }

      it { expect(conditions['active']).to eq true }
      it { expect(conditions['price']).to eq 42 }
      it { expect(conditions['title']).to eq 'foo' }
      it { expect(conditions['hidden']).to eq false }

    end
    
    describe 'decode regexps' do

      let(:source) { "{% with_scope title: /Like this one|or this one/ %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['title']).to eq(/Like this one|or this one/) }

    end

    describe 'decode regexps with case-insensitive' do

      let(:source) { "{% with_scope title: /like this/ix %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['title']).to eq(/like this/ix) }

    end

    describe 'decode content entry' do

      let(:entry) {
        instance_double('ContentEntry', _id: 1, _source: 'entity').tap do |_entry|
          allow(_entry).to receive(:to_liquid).and_return(_entry)
        end }
      let(:assigns) { { 'my_project' => entry } }
      let(:source)  { "{% with_scope project: my_project %}{% assign conditions = with_scope %}{% endwith_scope %}" }

      it { expect(conditions['project']).to eq 'entity' }

      context 'an array of content entries' do

        let(:source) { "{% with_scope project: [my_project, my_project, my_project] %}{% assign conditions = with_scope %}{% endwith_scope %}" }

        it { expect(conditions['project']).to eq ['entity', 'entity', 'entity'] }

      end

    end

    describe 'decode context variable' do

      let(:assigns) { { 'params' => { 'type' => 'posts' } } }
      let(:source) { "{% with_scope category: params.type %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['category']).to eq 'posts' }

    end

    describe 'decode a regexp stored in a context variable' do

      let(:assigns) { { 'my_regexp' => '/^Hello World/' } }
      let(:source) { "{% with_scope title: my_regexp %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['title']).to eq(/^Hello World/) }

    end

    describe 'decode a regexp stored in a context variable, with case-insensitive' do

      let(:assigns) { { 'my_regexp' => '/^hello world/ix' } }
      let(:source) { "{% with_scope title: my_regexp %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['title']).to eq(/^hello world/ix) }

    end

    describe 'allow order_by option' do

      let(:source) { "{% with_scope order_by:\'name DESC\' %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['order_by']).to eq 'name DESC' }

    end

    describe 'replace _permalink by _slug' do

      let(:source) { "{% with_scope _permalink: 'foo' %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['_slug']).to eq 'foo' }

    end

    describe 'decode criteria with gt and lt' do

      let(:source) { "{% with_scope price.gt: 42.0, price.lt:50, published_at.lte: '2019-09-10 00:00:00', published_at.gte: '2019/09/09 00:00:00' %}{% assign conditions = with_scope %}{% endwith_scope %}" }
      it { expect(conditions['price.gt']).to eq 42.0 }
      it { expect(conditions['price.lt']).to eq 50 }
      it { expect(conditions['published_at.lte']).to eq '2019-09-10 00:00:00' }
      it { expect(conditions['published_at.gte']).to eq '2019/09/09 00:00:00' }

    end

    describe 'In a loop context, each scope should be evaluated correctly' do
      let(:assigns) { {'list' => ['A', 'B', 'C']} }
      let(:source) { "{% for key in list %}{% with_scope foo: key %}{% assign conditions = with_scope %}{% endwith_scope %}{{ conditions }}{% endfor %}" }

      it { expect(output).to eq '{"foo"=>"A"}{"foo"=>"B"}{"foo"=>"C"}' }

    end

  end

  describe 'decode advanced options' do
    let(:options)  { "" }
    let(:source) { "{% with_scope key: #{options} %}{% assign conditions = with_scope %}{% endwith_scope %}" }

    before { output }
   
    context "Array" do
      context "of Integer" do
        let(:options)  { "[1, 2, 3]" }
        it { expect(conditions['key']).to eq [1, 2, 3] }
      end

      context "of String" do
        let(:options)  { "['a', 'b', 'c']" }
        it { expect(conditions['key']).to eq ['a', 'b', 'c'] }
      end

      context "With variable" do
        let(:assigns) { {'a' => 1, 'c' => 3} }
        let(:options) { "[a, 2, c, 'd']" }
        it { expect(conditions['key']).to eq [1, 2, 3, 'd'] }
      end
    end

    context "Hash" do
      context "With key value" do
        let(:options)  { "{a: 1, b: 2, c: 3, d: 'foo'}" }
        it { expect(conditions['key'].keys).to eq(%w(a b c d)) }
        it { expect(conditions['key']['a']).to eq 1 }
        it { expect(conditions['key']['b']).to eq 2 }
        it { expect(conditions['key']['c']).to eq 3 }
        it { expect(conditions['key']['d']).to eq 'foo' }
      end

      context "With key variable" do
        let(:assigns) { {'a' => 1, 'c' => 3} }
        let(:options)  { "{a: a, b: 2, c: c, d: 'foo'}" }
        it { expect(conditions['key'].keys).to eq(%w(a b c d)) }
        it { expect(conditions['key']['a']).to eq 1 }
        it { expect(conditions['key']['b']).to eq 2 }
        it { expect(conditions['key']['c']).to eq 3 }
        it { expect(conditions['key']['d']).to eq 'foo' }
      end

      context "With params" do
        let(:assigns) { { 'params' => Locomotive::Steam::Liquid::Drops::Params.new({ foo: 'bar' }) } }
        let(:options)  { "{'a': params.foo}" }
        it { expect(conditions['key'].keys).to eq(%w(a)) }
        it { expect(conditions['key']['a']).to eq 'bar' }
      end
    end
  end
end
