require 'erb'

module Locomotive::Steam
  module Adapters
    module Filesystem

      module YAMLLoader

        extend Forwardable

        def_delegators :@scope, :locales, :default_locale

        attr_reader :site_path, :env

        def initialize(site_path, env = :local)
          @site_path, @env = site_path, env
        end

        def load(scope = nil)
          @scope = scope
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

        def parse_erb(data)
          def inject(file_path)
            File.open(File.join(path, file_path)).read
          end
          ERB.new(data).result(binding)
        end

        def parse_erb_struct(vals)
          if vals.is_a? Array
            vals.each do | val |
              parse_erb_struct(val)
            end
          else
            vals.each do | key, val |
              if val.is_a? String
                vals[key] = parse_erb(val)
              else
                parse_erb_struct(val)
              end
            end
          end
        end

        def safe_yaml_load(yaml, template, path, &block)
          return {} if yaml.blank?

          erb_activated = parse_erb(yaml) != yaml

          begin
            HashConverter.to_sym(YAML.load(yaml)).tap do |attributes|
              if erb_activated
                parse_erb_struct(attributes)
              end
              block.call(attributes, template) if block_given?
            end
          rescue Exception => e
            raise "Malformed YAML in this file #{path}, error: #{e.message}"
          end
        end

        def safe_json_load(path)
          return {} unless File.exists?(path)

          json = parse_erb(File.read(path))

          begin
            MultiJson.load(json)
          rescue MultiJson::ParseError => e
            raise Locomotive::Steam::JsonParsingError.new(e, path, json)
          end
        end

        def template_extensions
          @extensions ||= %w(liquid haml)
        end

      end

    end
  end
end
