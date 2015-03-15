require_relative_all 'repositories'

module Locomotive
  module Steam

    class Repositories < Struct.new(:current_site, :locale, :configuration)

      include Morphine

      register :adapter do
        build_adapter(configuration.adapter)
      end

      register :site do
        SiteRepository.new(adapter, nil, locale)
      end

      register :page do
        PageRepository.new(adapter, current_site, locale)
      end

      register :snippet do
        SnippetRepository.new(adapter, current_site, locale)
      end

      register :content_type do
        ContentTypeRepository.new(adapter, current_site, locale)
      end

      register :content_entry do
        ContentEntryRepository.new(adapter, current_site, locale, content_type)
      end

      register :theme_asset do
        ThemeAssetRepository.new(adapter, current_site, locale)
      end

      register :translation do
        TranslationRepository.new(adapter, current_site, locale)
      end

      def build_adapter(options)
        name = ((options || {})[:name] || :filesystem).to_s
        require_relative "adapters/#{name}"
        klass = "Locomotive::Steam::#{name.camelize}Adapter".constantize
        klass.new(options)
      end

    end
  end
end
