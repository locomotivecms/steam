require 'spec_helper'

describe 'Locomotive::Steam::Liquid::Tags::Nav' do

  let(:index) { instance_double('IndexPage', fullpath: 'index', published: true) }
  let(:depth_1) do
    [
      instance_double('Child1', title: 'Child #1', slug: 'child-1', fullpath: 'child-1', published?: true, listed?: true, templatized?: false, to_liquid: { 'title' => 'Child #1' }),
      instance_double('Child2', title: 'Child #2', slug: 'child-2', fullpath: 'child-2', published?: true, listed?: true, templatized?: false, to_liquid: { 'title' => 'Child #2' })
    ]
  end
  let(:depth_2) do
    [
      instance_double('Child2_1', title: 'Child #2.1', slug: 'child-2-1', fullpath: 'child-2/child-2-1', published?: true, listed?: true, templatized?: false),
      instance_double('Child2_2', title: 'Child #2.2', slug: 'child-2-2', fullpath: 'child-2/child-2-2', published?: true, listed?: true, templatized?: false),
      instance_double('UnpublishedChild2_3', title: 'Child #2.3', slug: 'child-2-3', fullpath: 'child-2/child-2-3', published?: false, listed?: true, templatized?: false),
      instance_double('TemplatizedChild2_4', title: 'Child #2.4', slug: 'child-2-4', fullpath: 'child-2/child-2-4', published?: true, listed?: true, templatized?: true),
      instance_double('UnlistedChild2_4', title: 'Child #2.5', slug: 'child-2-5', fullpath: 'child-2/child-2-5', published?: true, listed?: false, templatized?: false)
    ]
  end

  let(:source)      { '{% nav site %}' }
  let(:site)        { instance_double('Site', name: 'My portfolio', default_locale: 'en') }
  let(:page)        { index }
  let(:services)    { Locomotive::Steam::Services.build_instance(nil) }
  let(:repository)  { services.repositories.page }
  let(:assigns)     { {} }
  let(:registers)   { { services: services, site: site, page: page } }
  let(:context)     { ::Liquid::Context.new(assigns, {}, registers) }
  let(:options)     { { services: services } }

  let(:output) { render_template(source, context, options) }

  before { services.repositories.current_site = site }

  describe 'rendering' do

    subject { output }

    describe 'from a site' do

      before do
        allow(repository).to receive(:root).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
      end

      it { is_expected.to eq %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/child-2">Child #2</a></li></ul></nav>} }

    end

    describe 'from a page' do

      let(:source) { '{% nav page %}' }

      before do
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
      end

      it { is_expected.to eq %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/child-2">Child #2</a></li></ul></nav>} }

    end

    describe 'from the parent page' do

      let(:source) { '{% nav parent %}' }

      describe 'no parent page, use the current page instead' do

        before do
          allow(repository).to receive(:parent_of).with(index).and_return(nil)
          allow(repository).to receive(:children_of).with(index).and_return(depth_1)
        end

        it { is_expected.to eq %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/child-2">Child #2</a></li></ul></nav>} }

      end

    end

    describe 'from a page' do

      let(:source) { '{% nav index %}' }

      describe 'no parent page, use the current page instead' do

        before do
          allow(repository).to receive(:by_fullpath).with('index').and_return(index)
          allow(repository).to receive(:children_of).with(index).and_return(depth_1)
        end

        it { is_expected.to eq %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/child-2">Child #2</a></li></ul></nav>} }

      end

    end

    describe 'no wrapper' do

      let(:source) { '{% nav site, no_wrapper: true %}' }

      before do
        allow(repository).to receive(:root).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
      end

      it { is_expected.to eq %{<li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/child-2">Child #2</a></li>} }

    end

    describe 'with icons' do

      before do
        allow(repository).to receive(:root).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
      end

      describe 'before' do

        let(:source) { '{% nav site, icon: before, no_wrapper: true %}' }
        it { is_expected.to include %{<li id="child-1-link" class="link first"><a href="/child-1"><span></span> Child #1</a></li>} }

      end

      describe 'after' do

        let(:source) { '{% nav site, icon: after, no_wrapper: true %}' }
        it { is_expected.to include %{<li id="child-1-link" class="link first"><a href="/child-1">Child #1 <span></span></a></li>} }

      end

    end

    describe 'including the second levels of pages (depth = 2)' do

      let(:source) { '{% nav site, depth: 2 %}' }

      before do
        allow(repository).to receive(:root).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
        allow(repository).to receive(:children_of).with(depth_1.first).and_return([])
        allow(repository).to receive(:children_of).with(depth_1.last).and_return(depth_2)
      end

      it { is_expected.to eq %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/child-2">Child #2</a><ul id="nav-child-2"><li id="child-2-1-link" class="link first"><a href="/child-2/child-2-1">Child #2.1</a></li>\n<li id="child-2-2-link" class="link last"><a href="/child-2/child-2-2">Child #2.2</a></li></ul></li></ul></nav>} }

      describe 'with bootstrap' do

        let(:source) { '{% nav site, bootstrap: true, depth: 2 %}' }
        it { is_expected.to eq %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown">Child #2 <b class="caret"></b></a><ul id="nav-child-2" class="dropdown-menu"><li id="child-2-1-link" class="link first"><a href="/child-2/child-2-1">Child #2.1</a></li>\n<li id="child-2-2-link" class="link last"><a href="/child-2/child-2-2">Child #2.2</a></li></ul></li></ul></nav>} }

      end

      describe 'excluding pages' do

        let(:source) { '{% nav site, depth: 2, exclude: "child-2/child-2-2" %}' }
        it { is_expected.to eq %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/child-2">Child #2</a><ul id="nav-child-2"><li id="child-2-1-link" class="link first last"><a href="/child-2/child-2-1">Child #2.1</a></li></ul></li></ul></nav>} }

      end

    end

    describe 'using a snippet to render the title' do

      let(:source) { %({% nav site, snippet: "{{page.title}}!" %}) }

      before do
        allow(repository).to receive(:root).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
        allow(repository).to receive(:root).and_return(index)
      end

      it { is_expected.to include %{<a href="/child-1">Child #1!</a>} }

      describe 'from a registered snippet' do

        let(:source)  { %({% nav site, snippet: nav_title %}) }
        let(:snippet) { instance_double('Snippet', source: '{{ page.title }}!') }

        before do
          allow(services.repositories.snippet).to receive(:by_slug).with('nav_title').and_return(snippet)
        end

        it { is_expected.to include %{<a href="/child-1">Child #1!</a>} }

      end

    end

    describe 'changing the dom id and the class' do

      let(:source) { %({% nav site, id: "main-nav", class: "nav" %}) }

      before do
        allow(repository).to receive(:root).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
      end

      it { is_expected.to include %{<nav id="main-nav" class="nav">} }

    end

    describe 'assigning a class other than "on" for a selected item' do

      let(:source)  { %({% nav parent, active_class: "active" %}) }
      let(:page)    { depth_1.first }

      before do
        allow(repository).to receive(:parent_of).with(page).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
      end

      it { is_expected.to include %{<li id="child-1-link" class="link active first">} }

    end

    describe 'localizing the links' do

      let(:source) { %({% nav parent, active_class: "active" %}) }

      before do
        services.url_builder.current_locale = 'fr'
        allow(repository).to receive(:parent_of).with(page).and_return(index)
        allow(repository).to receive(:children_of).with(index).and_return(depth_1)
      end

      it { is_expected.to include %{<nav id="nav"><ul><li id="child-1-link" class="link first"><a href="/fr/child-1">Child #1</a></li>\n<li id="child-2-link" class="link last"><a href="/fr/child-2">Child #2</a></li></ul></nav>} }

    end

  end

end
