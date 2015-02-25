require 'spec_helper'

require_relative '../../../lib/locomotive/steam/adapters/filesystem.rb'
require_relative '../../../lib/locomotive/steam/repositories/editable_element_repository.rb'

describe Locomotive::Steam::PageRepository do

  let(:pages)       { [{ title: { en: 'Home' }, handle: 'home', slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }] }
  let(:locale)      { :en }
  let(:site)        { instance_double('Site', _id: 1, default_locale: :en, locales: %i(en fr)) }
  let(:adapter)     { Locomotive::Steam::FilesystemAdapter.new(nil) }
  let(:repository)  { Locomotive::Steam::PageRepository.new(adapter, site, locale) }

  before do
    allow(adapter).to receive(:collection).and_return(pages)
    adapter.cache = NoCacheStore.new
  end

  describe '#all' do

    let(:pages) do
      [
        { title: { en: 'Contact' }, slug: { en: 'contact' }, _fullpath: 'contact', template_path: { en: 'contact.liquid' } },
        { title: { en: 'About us' }, position: 2, slug: { en: 'about-us' }, _fullpath: 'about-us', template_path: { en: 'about-us.liquid' } },
        { title: { en: 'Jane Doe' }, slug: { en: 'jane-doe' }, _fullpath: 'team/jane-doe', template_path: { en: 'team/jane-doe.liquid' } },
        { title: { en: 'John Doe' }, position: 1, slug: { en: 'john-doe' }, _fullpath: 'team/john-doe', template_path: { en: 'team/john-doe.liquid' } },
        { title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }
      ]
    end

    let(:conditions) { nil }

    subject { repository.all(conditions) }

    it { expect(subject.size).to eq 5 }

    describe 'default order' do

      subject { repository.all(conditions).map { |p| p.title.values.first } }

      it { is_expected.to eq ['Home', 'About us', 'Contact', 'John Doe', 'Jane Doe'] }

    end

    describe 'filter' do

      let(:conditions) { { slug: /-doe$/ } }
      it { expect(subject.size).to eq 2 }

    end

  end

  describe 'templatized pages' do

    let(:pages) do
      [
        { title: { en: 'Comments' }, slug: { en: 'comments' }, _fullpath: 'articles/template/comments' },
        { title: { en: 'Template Article' }, slug: { en: 'template' }, content_type: :articles, _fullpath: 'articles/template' },
        { title: { en: 'Articles' }, slug: { en: 'articles' }, _fullpath: 'articles' },
        { title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }
      ]
    end

    it { expect(repository.all.size).to eq 4 }
    it { expect(repository.find(2).templatized?).to eq true }

    describe 'nested templatized page' do

      subject { repository.find(1) }

      it { expect(subject.templatized?).to eq true }
      it { expect(subject.content_type).to eq :articles }
      it { expect(subject.slug[:en]).to eq 'comments' }
      it { expect(subject.slug[:fr]).to eq nil }
      it { expect(subject.fullpath[:en]).to eq 'articles/content_type_template/comments' }

    end

  end

  describe '#by_fullpath' do

    let(:path) { nil }
    subject { repository.by_fullpath(path) }

    it { is_expected.to eq nil }

    context 'existing page' do

      let(:path) { 'index' }
      it { expect(subject.title[:en]).to eq 'Home' }

    end

  end

  describe '#by_handle' do

    let(:handle) { nil }
    subject { repository.by_handle(handle) }

    it { is_expected.to eq nil }

    context 'existing page' do

      let(:handle) { 'home' }
      it { expect(subject.title[:en]).to eq 'Home' }

    end

  end

  describe '#matching_fullpath' do

    let(:paths) { nil }
    subject { repository.matching_fullpath(paths) }

    it { is_expected.to eq [] }

    context 'existing page' do

      let(:paths) { ['index', '404']  }
      it { expect(subject.first.title[:en]).to eq 'Home' }

    end

    context 'templatized page' do

      let(:paths) { ['articles/content_type_template', 'content_type_template/hello-world', 'articles/hello-world']  }

      let(:pages) do
        [{ title: { en: 'Templatized article' }, slug: { en: 'template' }, content_type: 'articles', _fullpath: 'articles/template', template_path: { en: 'articles/template.liquid' } }]
      end

      it { expect(subject.first.title[:en]).to eq('Templatized article') }

    end

  end

  describe '#template_for' do

    let(:pages) do
      [
        { title: { en: 'Article template' }, content_type: 'articles', slug: { en: 'articles/content_type_template' }, _fullpath: 'articles/template', template_path: { en: 'articles/template.liquid' } },
        { title: { en: 'Archived article template' }, handle: 'archive', content_type: 'articles', slug: { en: 'archived/articles/content_type_template' }, _fullpath: 'archived/articles/template', template_path: { en: 'archived/articles/template.liquid' } },
        { title: { en: 'Home' }, handle: 'home', slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }
      ]
    end
    let(:entry)   { nil }
    let(:handle)  { nil }

    subject { repository.template_for(entry, handle) }

    it { is_expected.to eq nil }

    context 'both existing entry and page' do

      let(:entry) { instance_double('Article', content_type_slug: 'articles', _slug: { en: 'hello-world' }) }
      it { expect(subject.title[:en]).to eq 'Article template' }
      it { expect(subject.content_entry).to eq entry }

      context 'with a handle' do

        let(:handle) { 'archive' }
        it { expect(subject.title[:en]).to eq 'Archived article template' }
        it { expect(subject.content_entry).to eq entry }

      end

    end

    context 'unknown content type' do

      let(:entry) { instance_double('Project', content_type_slug: 'projects', _slug: { en: 'hello-world' }) }
      it { is_expected.to eq nil }

    end

  end

  describe '#root' do

    subject { repository.root }
    it { expect(subject.title[:en]).to eq 'Home' }

  end

  describe '#parent_of' do

    let(:page) { nil }
    subject { repository.parent_of(page) }

    it { is_expected.to eq nil }

    context 'index' do

      let(:page) { instance_double('Page', index?: true) }
      it { is_expected.to eq nil }

    end

    context 'page not nil' do

      let(:page) { instance_double('Page', parent_id: 1, index?: false, fullpath: { en: 'about-us' }) }
      it { expect(subject.title[:en]).to eq 'Home' }

    end

    context 'nested pages' do

      let(:pages) do
        [
          { title: { en: 'Somewhere' }, slug: { en: 'somewhere' }, _fullpath: 'somewhere', template_path: { en: 'somewhere.liquid' } },
          { title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }
        ]
      end
      let(:page) { instance_double('Page', parent_id: 1, index?: false, fullpath: { en: 'somewhere/hello-world' }) }

      it { expect(subject.title[:en]).to eq 'Somewhere' }

    end

  end

  describe '#ancestors_of' do

    let(:page) { nil }
    subject { repository.ancestors_of(page) }

    it { is_expected.to eq [] }

    context 'index' do

      let(:page) { instance_double('Page', _id: 1, parent_ids: [], fullpath: 'index') }
      it { expect(subject.size).to eq 1 }
      it { expect(subject.first.title[:en]).to eq 'Home' }

    end

    context 'nested pages' do

      let(:pages) do
        [
          { title: { en: 'Foo' }, slug: { en: 'foo' }, _fullpath: 'bar/foo', template_path: { en: 'bar/foo.liquid' } },
          { title: { en: 'Bar' }, slug: { en: 'bar' }, _fullpath: 'bar', template_path: { en: 'bar.liquid' } },
          { title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }
        ]
      end
      let(:page) { instance_double('Page', _id: 1, parent_ids: [3, 2], title: { en: 'Foo' }, index?: false, fullpath: { en: 'bar/foo' }) }

      it { expect(subject.map { |p| p.title[:en] }).to eq ['Home', 'Bar', 'Foo'] }

    end

  end

  describe '#children_of' do

    let(:page) { nil }
    subject { repository.children_of(page) }

    it { is_expected.to eq [] }

    context 'with pages' do

      let(:pages) do
        [
          { title: { en: 'Foo' }, slug: { en: 'foo' }, _fullpath: 'bar/foo', template_path: { en: 'bar/foo.liquid' } },
          { title: { en: 'Bar' }, slug: { en: 'bar' }, _fullpath: 'bar', template_path: { en: 'bar.liquid' } },
          { title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', template_path: { en: 'index.liquid' } }
        ]
      end
      let(:page) { instance_double('Page', _id: 3, title: { en: 'Home' }, depth: 0, index?: true, fullpath: { en: 'index' }) }

      it { expect(subject.map { |p| p.title[:en] }).to eq ['Bar'] }

      context 'from a nested page' do

        let(:page) { instance_double('Page', _id: 2, title: { en: 'Bar' }, index?: false, depth: 1, fullpath: { en: 'bar' }) }
        it { expect(subject.map { |p| p.title[:en] }).to eq ['Foo'] }

      end

    end

  end

  describe '#editable_elements_of' do

    let(:page) { nil }
    subject { repository.editable_elements_of(page) }

    it { is_expected.to eq nil }

    context 'page with editable elements' do

      let(:elements) { [{ block: nil, slug: 'title', content: { en: 'Stuff here' } }] }
      let(:pages) do
        [
          { title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', editable_elements: elements, template_path: { en: 'index.liquid' } }
        ]
      end
      let(:page) { repository.all.first }

      it { expect(subject.all.size).to eq 1 }
      it { expect(subject.first.content[:en]).to eq 'Stuff here' }

      context 'changing the locale' do

        before { subject; repository.locale = :fr }

        it { expect(subject.locale).to eq :fr }

      end

    end

  end

  describe '#editable_element_for' do

    let(:page)  { nil }
    let(:block) { nil }
    let(:slug)  { nil }
    subject { repository.editable_element_for(page, block, slug) }

    it { is_expected.to eq nil }

    context 'page with editable elements' do

      let(:elements) { [{ block: nil, slug: 'title', content: { en: 'Stuff here', fr: 'Truc ici' } }] }
      let(:pages) do
        [
          { title: { en: 'Home' }, slug: { en: 'index' }, _fullpath: 'index', editable_elements: elements, template_path: { en: 'index.liquid' } }
        ]
      end
      let(:page)  { repository.all.first }
      let(:block) { nil }
      let(:slug)  { 'title' }

      it { expect(subject.content[:en]).to eq 'Stuff here' }

    end

  end

end
