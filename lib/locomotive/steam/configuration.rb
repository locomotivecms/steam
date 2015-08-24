module Locomotive
  module Steam

    class Configuration

      # Mainly used in the liquid templates (variable name: {{ mode }})
      # to distinguish the page rendered in Wagon (:test) or in the Engine.
      #
      # default: :production
      #
      attr_accessor :mode
      def mode; @mode || :production; end

      # Steam needs an adapter in order to fetch the site content (site itself, pages, content entries, ...etc).
      # By default, Steam is shipped with 2 adapters:
      #     - Filesystem (options: path). the path option should point to the root path of the site
      #     - MongoDB (options: database, hosts)
      #
      # default: { name: :filesytem, path: nil }
      #
      attr_accessor :adapter

      # Manage the list of middlewares used by the rack stack.
      #
      # Example:
      #
      #   Locomotive::Steam.configure do |config|
      #     ...
      #     config.middleware.remove Rack::Lint
      #     ...
      #     config.middleware.insert_after Middleware::Locale, MySlugMiddleware, answer: 42
      #     ...
      #   end
      #
      attr_accessor :middleware
      def middleware
        @middleware ||= Middlewares::StackProxy.new(&Locomotive::Steam::Server.default_middlewares)
      end

      # Add the checksum of a theme asset at the end of its path to allow public caching.
      #
      # default: false (disabled)
      #
      attr_accessor :theme_assets_checksum
      def theme_assets_checksum; @theme_assets_checksum.nil? ? false : @theme_assets_checksum; end

      # Enable serving of images, stylesheets, and JavaScripts from an asset server.
      # Useful if a CDN is used to serve assets.
      #
      # default: nil
      #
      attr_accessor :asset_host

      # Tell if Steam has to also serve static (images) or dynamic (SASS, Coffeescript) assets.
      #
      # default: true
      #
      attr_accessor :serve_assets
      def serve_assets; @serve_assets.nil? ? true : @serve_assets; end

      # Path to the assets (if Steam serves the assets).
      #
      # default: nil
      #
      attr_accessor :asset_path

      # If java is installed and if this option is enabled,
      # then YUI::JavaScriptCompressor and YUI::CssCompressor are used to minify the css and the javascript.
      #
      # default: false
      #
      attr_accessor :minify_assets
      def minify_assets; @minify_assets.nil? ? false : @minify_assets; end

      # Dragonfly needs it to generate the protective SHA.
      #
      # default: 'please change it'
      #
      attr_accessor :image_resizer_secret
      def image_resizer_secret; @image_resizer_secret.nil? ? 'please change it' : @image_resizer_secret; end

      # Enable the Cross-site request forgery protection for POST requests.
      #
      # default: true
      #
      attr_accessor :csrf_protection
      def csrf_protection; @csrf_protection.nil? ? true : @csrf_protection; end

      # Options for the store of Moneta (Session)
      #
      # default: { store: Moneta.new(:Memory, expires: true) }
      #
      attr_accessor :moneta
      def moneta; @moneta.nil? ? { store: Moneta.new(:Memory, expires: true) } : @moneta; end

      # Render a 404 page if no site has been found.
      # If Steam is embedded in another app, it's better to let the app handle
      # the no site case.
      #
      # default: true
      #
      attr_accessor :render_404_if_no_site
      def render_404_if_no_site; @render_404_if_no_site.nil? ? true : @render_404_if_no_site; end

      # Lambda called once a Services instance has been built.
      # It is used when we want to change one of the services
      #
      # Example:
      #
      # Locomotive::Steam.configure do |config|
      #
      #   config.services_hook = -> (services) {
      #     require 'my_custom_site_finder'
      #     services.site_finder = MyCustomSiteFinder.new
      #   }
      #
      # end
      #
      # default: nil
      #
      attr_accessor :services_hook

    end

  end
end
