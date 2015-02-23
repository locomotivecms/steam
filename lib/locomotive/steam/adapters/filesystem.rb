require_relative 'memory'

require_relative 'filesystem/simple_cache_store'

require_relative 'filesystem/yaml_loader'
require_relative 'filesystem/yaml_loaders/site'
require_relative 'filesystem/yaml_loaders/page'

require_relative 'filesystem/sanitizer'
require_relative 'filesystem/sanitizers/simple'
require_relative 'filesystem/sanitizers/page'

module Locomotive::Steam

  class FilesystemAdapter < Struct.new(:site_path)

    include Morphine

    register :cache do
      Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new
    end

    register :yaml_loaders do
      build_yaml_loaders(cache)
    end

    register :sanitizers do
      build_sanitizers
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
          default.where(site_id: scope.site._id)
        end
      end
    end

    def find(mapper, scope, id)
      _query(mapper, scope) { where(_id: id) }.first
    end

    private

    def _query(mapper, scope, &block)
      Locomotive::Steam::Adapters::Memory::Query.new(all(mapper, scope), scope.locale, &block)
    end

    def memoized_dataset(mapper, scope)
      return @datasets[mapper.name] if @datasets[mapper.name]
      dataset(mapper, scope)
    end

    def dataset(mapper, scope)
      Locomotive::Steam::Adapters::Memory::Dataset.new(mapper.name).tap do |dataset|
        @datasets[mapper.name] = dataset
        populate_dataset(dataset, mapper, scope)
      end
    end

    def populate_dataset(dataset, mapper, scope)
      sanitizers[mapper.name].with(scope) do |sanitizer|
        collection(mapper, scope).each do |attributes|
          entity = mapper.to_entity(attributes)
          dataset.insert(entity)

          sanitizer.apply_to(entity)
        end

        sanitizer.apply_to(dataset)
      end
    end

    def collection(mapper, scope)
      yaml_loaders[mapper.name].load(scope)
    end

    def build_yaml_loaders(cache)
      %i(sites pages).inject({}) do |memo, name|
        memo[name] = build_klass('YAMLLoaders', name).new(site_path, cache)
        memo
      end
    end

    def build_sanitizers
      hash = Hash.new { build_klass('Sanitizers', :simple).new }
      %i(pages).inject(hash) do |memo, name|
        memo[name] = build_klass('Sanitizers', name).new
        memo
      end
    end

    def build_klass(type, name)
      _name = name.to_s.singularize.camelize
      "Locomotive::Steam::Adapters::Filesystem::#{type}::#{_name}".constantize
    end

  end

end


