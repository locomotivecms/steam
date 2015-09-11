module Locomotive::Steam
  module Adapters
    module Filesystem

      module YAMLLoader

        attr_reader :site_path

        def initialize(site_path)
          @site_path = site_path
        end

        def load(scope = nil)
          @scope = scope
        end

        def default_locale
          @scope.default_locale
        end

        def _load(path, frontmatter = false, &block)
          if File.exists?(path)
            yaml      = File.open(path).read.force_encoding('utf-8')
            template  = nil

            if frontmatter && match = yaml.match(FRONTMATTER_REGEXP)
              yaml, template = match[:yaml], match[:template]
            end

            safe_yaml_load(yaml, template, path, &block)
          else
            Locomotive::Common::Logger.error "No #{path} file found"
            {}
          end
        end

        def safe_yaml_load(yaml, template, path, &block)
          return {} if yaml.blank?

          begin
            HashConverter.to_sym(YAML.load(yaml)).tap do |attributes|
              block.call(attributes, template) if block_given?
            end
          rescue Exception => e
            raise "Malformed YAML in this file #{path}, error: #{e.message}"
          end
        end

        def template_extensions
          @extensions ||= %w(liquid haml)
        end

      end

    end
  end
end
