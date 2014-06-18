module Locomotive
  module Steam
    module Utils

      # YAML Front-matters for HAML/Liquid templates
      class YAMLFrontMattersTemplate

        attr_reader :filepath

        def initialize(filepath)
          @filepath     = filepath
          @line_offset  = 0
          @parsed = false
        end

        def attributes
          self.fetch_attributes_and_raw_source
          @attributes
        end

        def raw_source
          self.fetch_attributes_and_raw_source
          @raw_source
        end

        def line_offset
          self.fetch_attributes_and_raw_source
          @line_offset
        end

        def source
          self.fetch_attributes_and_raw_source
          return @source if @source

          @source = if self.filepath.ends_with?('.haml')
            Haml::Engine.new(self.raw_source).render
          else
            self.raw_source
          end
        end

        def data
          @data ||= File.read(filepath)
        end

        protected
        def parsed?
          @parsed
        end
        def fetch_attributes_and_raw_source
          return if @parsed
          if data =~ /^(---\s*\n.*?\n?)^(---\s*$\n?)(.*)/m
            @line_offset  = $1.count("\n") + 1
            @attributes   = YAML.load($1)
            @raw_source   = $3
          else
            @attributes = {}
            @raw_source = data
          end
          @raw_source.force_encoding('utf-8')
          @parsed = true
        end
      end
    end
  end
end
