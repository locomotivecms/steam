module Locomotive
  module Steam
    module Liquid

      # A Liquid file system is a way to let your templates retrieve other templates for use with the include and sections tags.
      #
      # Example:
      #
      #   Liquid::Template.file_system = Liquid::LocalFileSystem.new(template_path)
      #   liquid = Liquid::Template.parse(template)
      #
      # This will parse the template from both the DB or the Filesystem.
      #
      class FileSystem

        attr_reader :section_finder, :snippet_finder

        def initialize(section_finder: nil, snippet_finder: nil)
          @section_finder, @snippet_finder = section_finder, snippet_finder
        end

        # Called by Liquid to retrieve a template file
        def read_template_file(_template_path)
          type, name = _template_path.split('--')

          entity = (
            case type
            when 'sections'
              section_finder.find(name)
            when 'snippet'
              snippet_finder.find(name)
            else
              raise ::Liquid::FileSystemError, "This liquid context does not allow #{type}."
            end
          )

          entity.liquid_source
        end

      end

    end
  end
end
