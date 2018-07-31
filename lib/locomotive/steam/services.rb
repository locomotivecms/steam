require 'morphine'

require_relative_all %w(concerns .), 'services'

module Locomotive
  module Steam

    module Services

      def self.build_instance(request = nil)
        Instance.new(request).tap do |instance|
          if Locomotive::Steam.configuration.services_hook
            Locomotive::Steam.configuration.services_hook.call(instance)
          end
        end
      end

      # Used to get an easy access to some of the services (url_builder)
      # without passing a request
      def self.build_simple_instance(site)
        Instance.new(nil).tap do |instance|
          instance.current_site = site
        end
      end

      class Defer < SimpleDelegator
        def initialize(&block)
          @constructor = block
          super(nil)
        end
        def __getobj__
          super || __setobj__(@constructor.call)
        end
        def nil?
          __getobj__.nil?
        end
      end

      class Instance

        include Morphine

        attr_accessor_initialize :request

        register :current_site do
          repositories.current_site = Defer.new { site_finder.find }
        end

        register :repositories do
          Steam::Repositories.new(nil, nil, configuration)
        end

        register :site_finder do
          Steam::SiteFinderService.new(repositories.site, request)
        end

        register :page_finder do
          Steam::PageFinderService.new(repositories.page)
        end

        register :parent_finder do
          Steam::ParentFinderService.new(repositories.page)
        end

        register :editable_element do
          Steam::EditableElementService.new(repositories.page, locale)
        end

        register :snippet_finder do
          Steam::SnippetFinderService.new(repositories.snippet)
        end

        register :section_finder do
          Steam::SectionFinderService.new(repositories.section)
        end

        register :action do
          Steam::ActionService.new(current_site, email, content_entry: content_entry, api: external_api, redirection: page_redirection)
        end

        register :content_entry do
          Steam::ContentEntryService.new(repositories.content_type, repositories.content_entry, locale)
        end

        register :entry_submission do
          Steam::EntrySubmissionService.new(content_entry)
        end

        register :liquid_parser do
          Steam::LiquidParserService.new(parent_finder, snippet_finder)
        end

        register :url_builder do
          Steam::UrlBuilderService.new(current_site, locale, request&.env&.fetch('steam.mounted_on', nil))
        end

        register :url_finder do
          Steam::UrlFinderService.new(url_builder, page_finder, content_entry)
        end

        register :page_redirection do
          Steam::PageRedirectionService.new(page_finder, url_builder)
        end

        register :theme_asset_url do
          Steam::ThemeAssetUrlService.new(repositories.theme_asset, asset_host, configuration.theme_assets_checksum)
        end

        register :asset_host do
          Steam::AssetHostService.new(request, current_site, configuration.asset_host)
        end

        register :image_resizer do
          Steam::ImageResizerService.new(::Dragonfly.app(:steam), configuration.asset_path)
        end

        register :translator do
          Steam::TranslatorService.new(repositories.translation, locale)
        end

        register :external_api do
          Steam::ExternalAPIService.new
        end

        register :csrf_protection do
          Steam::CsrfProtectionService.new(configuration.csrf_protection, Rack::Csrf.field, Rack::Csrf.token(request.env))
        end

        register :markdown do
          Steam::MarkdownService.new
        end

        register :textile do
          Steam::TextileService.new
        end

        register :email do
          Steam::EmailService.new(page_finder, liquid_parser, asset_host, configuration.mode == :test)
        end

        register :auth do
          Steam::AuthService.new(current_site, content_entry, email)
        end

        register :cache do
          Steam::NoCacheService.new
        end

        register :configuration do
          Locomotive::Steam.configuration
        end

        register :locale do
          I18n.locale
        end

        def locale
          @locale || I18n.locale
        end

        def locale=(locale)
          # Note: "repositories" has already been initialized when called here.
          @locale = repositories.locale = locale
        end

        def set_site(site)
          self.current_site.__setobj__(site)
        end

        def defer(name, &block)
          send(:"#{name}=", Defer.new(&block))
        end

      end

    end

  end
end
