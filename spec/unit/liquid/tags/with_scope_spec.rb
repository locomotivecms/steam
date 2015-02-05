require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::WithScope do

  let(:assigns)     { {} }
  let(:context)     { ::Liquid::Context.new(assigns, {}, {}) }
  let!(:output)     { render_template(source, context) }
  let(:conditions)  { context['conditions'] }

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

  describe 'allow order_by option' do

    let(:source) { "{% with_scope order_by:\'name DESC\' %}{% assign conditions = with_scope %}{% endwith_scope %}" }
    it { expect(conditions['order_by']).to eq 'name DESC' }

  end

  describe 'replace _permalink by _slug' do

    let(:source) { "{% with_scope _permalink: 'foo' %}{% assign conditions = with_scope %}{% endwith_scope %}" }
    it { expect(conditions['_slug']).to eq 'foo' }

  end

  describe 'decode criteria with gt and lt' do

    let(:source) { "{% with_scope price.gt:42.0, price.lt:50 %}{% assign conditions = with_scope %}{% endwith_scope %}" }
    it { expect(conditions['price.gt']).to eq 42.0 }
    it { expect(conditions['price.lt']).to eq 50 }

  end

end
