require_relative 'middlewares/stack_proxy'

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

      # Steam is also able to serve a local Wagon site. The following property
      # should point to the root path of the site.
      #
      # default: nil
      #
      attr_accessor :site_path

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
      # If the site_path property is not nil, the assets_path
      # will point to the "public" sub folder of the site.
      #
      # default: nil
      #
      attr_accessor :assets_path
      def assets_path
        return @assets_path if @assets_path
        site_path ? File.join(site_path, 'public') : nil
      end

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

      # Lambda called once a Services instance has been built.
      # It is used when we want to change one of the services
      #
      # Example:
      #
      # Locomotive::Steam.configure do |config|
      #
      #   config.services_hook = -> (services) {
      #     require 'my_repositories'
      #     services.repositories = MyRepositories.new
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
