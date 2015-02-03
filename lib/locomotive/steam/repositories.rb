Dir[File.join(File.dirname(__FILE__), 'repositories', '*.rb')].each { |lib| require lib }

require 'morphine'

module Locomotive
  module Steam
    module Repositories

      def self.build_instance(site = nil)
        Registered.new(site)
      end

      class Registered < Struct.new(:current_site)

        include Morphine

        register :site do
          Repositories::Site.new
        end

        register :page do
          Repositories::Page.new(current_site)
        end

        register :snippet do
          Repositories::Snippet.new(current_site)
        end

        register :theme_asset do
          Repositories::ThemeAsset.new(current_site)
        end

        register :translation do
          Repositories::Translation.new(current_site)
        end

      end

    end
  end
end
