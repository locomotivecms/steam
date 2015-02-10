Dir[File.join(File.dirname(__FILE__), 'repositories', 'filesystem', '*.rb')].each { |lib| require lib }
Dir[File.join(File.dirname(__FILE__), 'repositories', '*.rb')].each { |lib| require lib }

require 'morphine'

module Locomotive
  module Steam
    module Repositories

      def self.build_instance(site = nil, current_locale = nil)
        Instance.new(site, current_locale)
      end

      class Instance < Struct.new(:current_site, :current_locale)

        include Morphine

        register :site do
          Steam::Repositories::Filesystem::Site.new
        end

        register :page do
          Steam::Repositories::Filesystem::Page.new(current_site, current_locale)
          # Steam::Repositories::Page.new(current_site, current_locale)
        end

        register :content_type do
          Steam::Repositories::ContentType.new(current_site)
        end

        register :content_entry do
          Steam::Repositories::ContentEntry.new(current_site)
        end

        register :snippet do
          Steam::Repositories::Snippet.new(current_site)
        end

        register :theme_asset do
          Steam::Repositories::ThemeAsset.new(current_site)
        end

        register :translation do
          Steam::Repositories::Translation.new(current_site)
        end

      end

    end
  end
end
