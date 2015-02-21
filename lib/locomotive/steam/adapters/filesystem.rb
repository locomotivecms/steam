# require_relative_all 'yaml_loaders'
require_relative 'filesystem/dataset'
require_relative 'filesystem/condition'
require_relative 'filesystem/query'

require_relative 'filesystem/simple_cache_store'

require_relative 'filesystem/yaml_loader'
require_relative 'filesystem/yaml_loaders/site'

module Locomotive::Steam

  class FilesystemAdapter

    include Morphine

    register :cache do
      Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new
    end

    def initialize(site_path)
      @site_path  = site_path
      @datasets   = {}
    end

    def all(mapper)
      memoized_dataset(mapper)
    end

    def query(mapper, locale, &block)
      Locomotive::Steam::Adapters::Filesystem::Query.new(all(mapper), locale, &block)
    end

    private

    def memoized_dataset(mapper)
      return @datasets[mapper.name] if @datasets[mapper.name]
      dataset(mapper)
    end

    def dataset(mapper)
      Locomotive::Steam::Adapters::Filesystem::Dataset.new(mapper.name).tap do |dataset|
        @datasets[mapper.name] = dataset

        collection(mapper).each do |attributes|
          entity = mapper.to_entity(attributes)
          dataset.insert(entity)
        end
      end
    end

    def collection(mapper)
      yaml_loader(mapper.name).load
    end

    def yaml_loader(name)
      _name = name.to_s.singularize.camelize
      klass = "Locomotive::Steam::Adapters::Filesystem::YAMLLoaders::#{_name}".constantize
      klass.new(@site_path, cache)
    end

  end

end


