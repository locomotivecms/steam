require_relative 'memory'

require_relative 'filesystem/simple_cache_store'

require_relative 'filesystem/yaml_loader'
require_relative_all 'filesystem/yaml_loaders'

require_relative 'filesystem/sanitizer'
require_relative_all 'filesystem/sanitizers'

module Locomotive::Steam

  class FilesystemAdapter < Struct.new(:options)

    include Morphine
    include Locomotive::Steam::Adapters::Concerns::Key

    register :cache do
      Locomotive::Steam::Adapters::Filesystem::SimpleCacheStore.new
    end

    register(:yaml_loaders)  { build_yaml_loaders }
    register(:sanitizers)    { build_sanitizers }

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

    def create(mapper, scope, entity)
      sanitizers[mapper.name].with(scope) do |sanitizer|
        dataset = memoized_dataset(mapper, scope)
        dataset.insert(entity)
        sanitizer.apply_to_entity_with_dataset(entity, dataset)
      end
    end

    def find(mapper, scope, id)
      _query(mapper, scope) { where(_id: id) }.first
    end

    def base_url(mapper, scope, entity = nil)
      ''
    end

    private

    def _query(mapper, scope, &block)
      Locomotive::Steam::Adapters::Memory::Query.new(all(mapper, scope), scope.locale, &block)
    end

    def memoized_dataset(mapper, scope)
      cache.fetch(cache_key(mapper, scope)) do
        dataset(mapper, scope)
      end
    end

    def cache_key(mapper, scope)
      "#{scope.to_key}_#{mapper.name}"
    end

    def dataset(mapper, scope)
      Locomotive::Steam::Adapters::Memory::Dataset.new(mapper.name).tap do |dataset|
        populate_dataset(dataset, mapper, scope)
      end
    end

    def populate_dataset(dataset, mapper, scope)
      sanitizers[mapper.name].with(scope) do |sanitizer|
        collection(mapper, scope).each do |attributes|
          entity = mapper.to_entity(attributes.dup)

          dataset.insert(entity)
          sanitizer.apply_to(entity)
        end

        sanitizer.apply_to(dataset)
      end
    end

    def collection(mapper, scope)
      yaml_loaders[mapper.name].load(scope)
    end

    def build_yaml_loaders
      %i(sites pages content_types content_entries snippets translations theme_assets).inject({}) do |memo, name|
        memo[name] = build_klass('YAMLLoaders', name).new(site_path)
        memo
      end
    end

    def build_sanitizers
      hash = Hash.new { build_klass('Sanitizers', :simple).new }
      %i(pages content_types content_entries snippets).inject(hash) do |memo, name|
        memo[name] = build_klass('Sanitizers', name).new
        memo
      end
    end

    def build_klass(type, name)
      _name = name.to_s.singularize.camelize
      "Locomotive::Steam::Adapters::Filesystem::#{type}::#{_name}".constantize
    end

    def site_path
      options.respond_to?(:has_key?) ? options[:path] : options
    end

  end

end


