require_relative_all 'repositories'

module Locomotive
  module Steam

    class Repositories < Struct.new(:site, :locale, :configuration)

      include Morphine

      register :adapter do
        require_relative 'adapters/filesystem'
        Steam::FilesystemAdapter.new(configuration.site_path)
      end

      register :site do
        SiteRepository.new(adapter, nil, locale)
      end

      register :page do
        PageRepository.new(adapter, site, locale)
      end

      register :snippet do
        SnippetRepository.new(adapter, site, locale)
      end

      register :content_type do
        ContentTypeRepository.new(adapter, site, locale)
      end

      register :content_entry do
        ContentEntryRepository.new(adapter, site, locale, content_type)
      end

      register :theme_asset do
        ThemeAssetRepository.new(adapter, site, locale)
      end

      register :translation do
        TranslationRepository.new(adapter, site, locale)
      end

    end
  end
end
