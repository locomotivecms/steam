module Locomotive
  module Steam
    module Loader
      module Yml
        class PagesLoader
          def initialize(path, mapper)
            @root_path  = path
            @path = File.join(path, 'app', 'views', 'pages')
            @mapper = mapper
          end


          # Build the tree of pages based on the filesystem structure
          #
          # @return [ Hash ] The pages organized as a Hash (using the fullpath as the key)
          #
          def load!
            entity_class = @mapper.collection(:pages).entity
            repository = @mapper.collection(:pages).repository
            all.each do |record|
              page = entity_class.new(record)
              repository.create page, :en

            end
          end

          protected

          # Create a ordered list of pages from the Hash
          #
          # @return [ Array ] An ordered list of pages
          #
          def pages_to_list
            # sort by fullpath first
            list = self.pages.values.sort { |a, b| a.fullpath <=> b.fullpath }
            # sort finally by depth
            list.sort { |a, b| a.depth <=> b.depth }
          end

          def build_relationships(parent, list)
            # do not use an empty template for other locales than the default one
            parent.set_default_template_for_each_locale(self.default_locale)

            list.dup.each do |page|
              next unless self.is_subpage_of?(page.fullpath, parent.fullpath)

              # attach the page to the parent (order by position), also set the parent
              parent.add_child(page)

              # localize the fullpath in all the locales
              page.localize_fullpath

              # remove the page from the list
              list.delete(page)

              # go under
              self.build_relationships(page, list)
            end
          end

          # Record pages found in file system
          def all
            [].tap do |page_records|
              position, last_dirname = nil, nil

              Dir.glob(File.join(root_dir, '**/*')).sort.each do |filepath|
                next unless File.directory?(filepath) || filepath =~ /\.(#{Locomotive::Steam::TEMPLATE_EXTENSIONS.join('|')})$/

                if last_dirname != File.dirname(filepath)
                  position, last_dirname = 100, File.dirname(filepath)
                end

                page = page_attributes(filepath)
                page[:position] = position

                page_records << page
                position += 1
              end
            end
          end

          def page_attributes(filepath)
            {}.tap do |attributes|
              fullpath = self.filepath_to_fullpath(filepath)
              attributes[:title]    = File.basename(fullpath).humanize
              attributes[:fullpath] = fullpath
              attributes[:template] = OpenStruct.new(raw_source: '') if File.directory?(filepath)
              attributes.merge(get_attributes_from_header(filepath)) unless File.directory?(filepath)
            end
          end

          # Set attributes of a page from the information
          # stored in the header of the template (YAML matters).
          # It also stores the template.
          #
          # @param [ Object ] page The page
          # @param [ String ] filepath The path of the template
          #
          def get_attributes_from_header(filepath)
            {}.tap do |attributes|
              template = Locomotive::Steam::Utils::YAMLFrontMattersTemplate.new(filepath)

              if template.attributes
                attributes.merge(template.attributes)

                if content_type_slug = attributes.delete('content_type')
                  attributes[:templatized]   = true
                  attributes[:content_type]  = Locomotive::Models[:content_types][content_type_slug]
                end
              end

              attributes[:template] = template
            end
          end

          # Return the directory where all the templates of
          # pages are stored in the filesystem.
          #
          # @return [ String ] The root directory
          #
          def root_dir
            @path
          end

          # Take the path to a file on the filesystem
          # and return its matching value for a Page.
          #
          # @param [ String ] filepath The path to the file
          #
          # @return [ String ] The fullpath of the page
          #
          def filepath_to_fullpath(filepath)
            fullpath = filepath.gsub(File.join(self.root_dir, '/'), '')

            fullpath.gsub!(/^\.\//, '')

            fullpath.split('.').first.dasherize
          end

          # Tell is a page described by its fullpath is a sub page of a parent page
          # also described by its fullpath
          #
          # @param [ String ] fullpath The full path of the page to test
          # @param [ String ] parent_fullpath The full path of the parent page
          #
          # @return [ Boolean] True if the page is a sub page of the parent one
          #
          def is_subpage_of?(fullpath, parent_fullpath)
            return false if %w(index 404).include?(fullpath)

            if parent_fullpath == 'index' && fullpath.split('/').size == 1
              return true
            end

            File.dirname(fullpath.dasherize) == parent_fullpath.dasherize
          end
        end
      end
    end
  end
end
