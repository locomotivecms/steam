module Locomotive::Steam
  module Adapters
    module Filesystem

      module JSONLoader

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
            json      = File.open(path).read.force_encoding('utf-8')
            template  = nil

            if frontmatter && match = json.match(FRONTMATTER_REGEXP)
              json, template = match[:json], match[:template]
            end

            safe_json_load(json, template, path, &block)
          else
            Locomotive::Common::Logger.error "No #{path} file found"
            {}
          end
        end

        def safe_json_load(json, template, path, &block)
          return {} if json.blank?

          begin
            HashConverter.to_sym(JSON.load(json)).tap do |attributes|
              block.call(attributes, template) if block_given?
            end
          rescue Exception => e
            raise "Malformed JSON in this file #{path}, error: #{e.message}"
          end
        end

        def template_extensions
          @extensions ||= %w(liquid haml)
        end

      end

    end
  end
end
