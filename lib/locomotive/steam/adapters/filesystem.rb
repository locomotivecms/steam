require_relative 'filesystem/dataset'
require_relative 'filesystem/order'
require_relative 'filesystem/condition'
require_relative 'filesystem/query'

require_relative 'filesystem/simple_cache_store'

require_relative 'filesystem/yaml_loader'
require_relative 'filesystem/yaml_loaders/site'
require_relative 'filesystem/yaml_loaders/page'

module Locomotive::Steam

  class FilesystemAdapter < Struct.new(:site_path)

    include Morphine

    register :cache do
      Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new
    end

    register :yaml_loaders do
      build_yaml_loaders(cache)
    end

    def initialize(site_path)
      super
      @datasets = {}
    end

    def all(mapper, scope)
      memoized_dataset(mapper, scope)
    end

    def query(mapper, scope, &block)
      _query(mapper, scope, &block).tap do |default|
        if scope.site
          default.where(site_id: scope.site.id)
        end
      end
    end

    private

    def _query(mapper, scope, &block)
      Locomotive::Steam::Adapters::Filesystem::Query.new(all(mapper, scope), scope.locale, &block)
    end

    def memoized_dataset(mapper, scope)
      return @datasets[mapper.name] if @datasets[mapper.name]
      dataset(mapper, scope)
    end

    def dataset(mapper, scope)
      Locomotive::Steam::Adapters::Filesystem::Dataset.new(mapper.name).tap do |dataset|
        @datasets[mapper.name] = dataset

        collection(mapper, scope).each do |attributes|
          entity = mapper.to_entity(attributes)

          # assign the site_id to the entity + sanitize attributes
          # specific to the Filesystem adapter
          entity[:site_id] = scope.site.id if scope.site

          dataset.insert(entity)
        end
      end
    end

    def collection(mapper, scope)
      yaml_loaders[mapper.name].load(scope)
    end

    def build_yaml_loaders(cache)
      %i(site page).inject({}) do |memo, name|
        _name = name.to_s.singularize.camelize
        klass = "Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::#{_name}".constantize
        memo[name] = klass.new(site_path, cache)
      end
    end

  end

end


