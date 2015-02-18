require_relative 'filesystem/models/concerns/validation.rb'
require_relative 'filesystem/models/base'
require_relative 'filesystem/concerns/queryable.rb'
require_relative 'filesystem/yaml_loaders/concerns/common.rb'
require_relative_all %w(memory_adapter yaml_loaders sanitizers models .), 'filesystem'

module Locomotive
  module Steam
    module Repositories
      module Filesystem

        def self.build_instance(site = nil, current_locale = nil, path = nil)
          Instance.new(site, current_locale, path)
        end

        class Instance < Struct.new(:current_site, :current_locale, :path)

          include Morphine

          register :site do
            Filesystem::Site.new(
              YAMLLoaders::Site.new(path, cache))
          end

          register :page do
            Filesystem::Page.new(
              YAMLLoaders::Page.new(path, current_site.try(:default_locale), cache),
              current_site, current_locale)
          end

          register :snippet do
            Filesystem::Snippet.new(
              YAMLLoaders::Snippet.new(path, current_site.try(:default_locale), cache),
              current_site, current_locale)
          end

          register :content_type do
            Filesystem::ContentType.new(
              YAMLLoaders::ContentType.new(path, cache),
              current_site, current_locale)
          end

          register :content_entry do
            Filesystem::ContentEntry.new(
              YAMLLoaders::ContentEntry.new(path, cache),
              current_site, current_locale, content_type)
          end

          register :theme_asset do
            Filesystem::ThemeAsset.new(current_site)
          end

          register :translation do
            Filesystem::Translation.new(
              YAMLLoaders::Translation.new(path, cache))
          end

          register :cache do
            Filesystem::MemoryAdapter::SimpleCacheStore.new
          end

        end

      end
    end
  end
end
