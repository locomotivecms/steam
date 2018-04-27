require_relative_all 'repositories'

module Locomotive
  module Steam

    class Repositories

      include Morphine

      attr_accessor_initialize :current_site, :locale, :configuration

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

      register :section do
        SectionRepository.new(adapter, current_site, locale)
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
        begin
          require_relative "adapters/#{name.downcase}"
        rescue LoadError => e
          puts 'Not a Steam built-in adapter'
          puts e.inspect
          puts e.backtrace
        end
        klass = "Locomotive::Steam::#{name.camelize}Adapter".constantize
        klass.new(options)
      end

    end
  end
end
