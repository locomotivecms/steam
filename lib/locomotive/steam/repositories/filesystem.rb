require_relative 'filesystem/models/base'
require_relative 'filesystem/concerns/queryable.rb'
require_relative 'filesystem/yaml_loaders/concerns/common.rb'

%w(memory_adapter yaml_loaders sanitizers models .).each do |name|
  Dir[File.join(File.dirname(__FILE__), 'filesystem', name, '*.rb')].each { |lib| require lib }
end

module Locomotive
  module Steam
    module Repositories
      module Filesystem

        def self.build_instance(site = nil, current_locale = nil, options = {})
          Instance.new(site, current_locale, options)
        end

        class Instance < Struct.new(:current_site, :current_locale, :options)

          include Morphine

          register :site do
            loader = YAMLLoaders::Site.new(options[:path], cache)
            Filesystem::Site.new(loader)
          end

          register :page do
            loader = YAMLLoaders::Page.new(options[:path], current_site.try(:default_locale), cache)
            Filesystem::Page.new(loader, current_site, current_locale)
          end

          register :snippet do
            loader = YAMLLoaders::Snippet.new(options[:path], current_site.try(:default_locale), cache)
            Filesystem::Snippet.new(loader, current_site, current_locale)
          end

          register :content_type do
            Filesystem::ContentType.new(current_site)
          end

          register :content_entry do
            Filesystem::ContentEntry.new(current_site)
          end

          register :theme_asset do
            Filesystem::ThemeAsset.new(current_site)
          end

          register :translation do
            loader = YAMLLoaders::Translation.new(options[:path], cache)
            Filesystem::Translation.new(loader, current_site)
          end

          register :cache do
            Filesystem::MemoryAdapter::SimpleCacheStore.new
          end

        end

      end
    end
  end
end
