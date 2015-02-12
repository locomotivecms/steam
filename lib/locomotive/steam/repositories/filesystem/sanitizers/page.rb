module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module Sanitizers

          class Page < Struct.new(:collection, :locales)

            def initialize(collection, locales)
              super

              @content_types  = {}
              @localized      = {}
              locales.each { |locale| @localized[locale] = {} }
            end

            def apply
              sorted_collection.each do |page|
                locales.each do |locale|
                  set_fullpath_for(page, locale)
                  modify_if_templatized(page, locale)
                  build_editable_elements(page, locale)
                end
              end
            end

            def build_editable_elements(page, locale)
              elements = page.editable_elements[locale] || {}
              elements.stringify_keys!

              elements.each do |name, content|
                segments    = name.split('/')
                block, slug = segments[0..-2].join('/'), segments.last
                block       = nil if block.blank?

                elements[name] = Filesystem::Models::EditableElement.new(block, slug, content)
              end
            end

            def modify_if_templatized(page, locale)
              content_type = fetch_content_type(parent_fullpath(page))

              if page.templatized? && content_type.nil?
                # change the slug of a templatized page
                page[:slug][locale] = 'content_type_template'

                # make sure its children will have its content type
                set_content_type(page._fullpath, page.content_type)
              else
                page[:content_type] = content_type
              end
            end

            def set_fullpath_for(page, locale)
              page._fullpath ||= page.attributes.delete(:_fullpath)

              slug = fullpath = page.slug[locale].try(:dasherize)

              return if slug.blank?

              if page.depth > 1
                base = parent_fullpath(page)
                fullpath = (fetch_localized_fullpath(base, locale) || base) + '/' + slug
              end

              set_localized_fullpath(page._fullpath, fullpath, locale)
              page[:fullpath][locale] = fullpath
            end

            def depth(page)
              return page.depth if page.depth

              page.depth = page[:_fullpath].split('/').size

              if page.depth == 1 && (page.slug == 'index' || page.slug == '404')
                page.depth = 0
              end

              page.depth
            end

            def sorted_collection
              collection.sort { |a, b| depth(a) <=> depth(b) }
            end

            def parent_fullpath(page)
              page._fullpath.split('/')[0..-2].join('/')
            end

            def fetch_content_type(fullpath)
              @content_types[fullpath]
            end

            def set_content_type(fullpath, value)
              @content_types[fullpath] = value
            end

            def fetch_localized_fullpath(fullpath, locale)
              @localized[locale][fullpath]
            end

            def set_localized_fullpath(fullpath, value, locale)
              @localized[locale][fullpath] = value
            end

          end

        end
      end
    end
  end
end
