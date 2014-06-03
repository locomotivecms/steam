module Locomotive
  module Steam
    module Loader
      module Yml
        class SiteLoader
          def initialize(path, mapper)
            @root_path  = path
            @path       = File.join(@root_path, 'config', 'site.yml')
            @mapper = mapper
          end

          def load!
            entity_class = @mapper.collection(:sites).entity
            repository = @mapper.collection(:sites).repository
            all.each do |site_hash|
              site = entity_class.new(site_hash)
              repository.create site, site_hash['locales'].first
            end
          end

          private

          def all
            attributes = load_attributes
            (attributes['domains'] ||= []) << '0.0.0.0'
            [attributes]
          end

          def load_attributes
            if File.exists?(@path)
              file = File.read(@path).force_encoding('utf-8')
              YAML::load(file)
            else
              raise "#{@path} was not found"
            end
          end
        end
      end
    end
  end
end