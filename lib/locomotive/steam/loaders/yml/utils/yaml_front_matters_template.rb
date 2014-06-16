module Locomotive
  module Steam
    module Utils

      # YAML Front-matters for HAML/Liquid templates
      class YAMLFrontMattersTemplate

        attr_accessor :filepath, :attributes, :raw_source, :line_offset

        def initialize(filepath)
          self.filepath     = filepath
          self.line_offset  = 0

          self.fetch_attributes_and_raw_source(File.read(self.filepath))
        end

        def source
          return @source if @source

          @source = if self.filepath.ends_with?('.haml')
            Haml::Engine.new(self.raw_source).render
          else
            self.raw_source
          end
        end

        protected

        def fetch_attributes_and_raw_source(data)
          if data =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
            self.line_offset  = $1.count("\n") + 1
            self.attributes   = YAML.load($1)
            self.raw_source   = $3
          else
            self.attributes = nil
            self.raw_source = data
          end

          self.raw_source = self.raw_source.force_encoding('utf-8')
        end

      end
    end
  end
end
