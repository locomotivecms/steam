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
                  modify_if_templatized(page, locale)
                  set_fullpath_for(page, locale)
                end
              end
            end

            def modify_if_templatized(page, locale)
              content_type = fetch_content_type(parent_fullpath(page))

              if page.templatized? && content_type.nil?
                # change the slug of a templatized page
                page.attributes[:slug][locale] = 'content_type_template'

                # make sure its children will have its content type
                set_content_type(page._fullpath, page.content_type)
              else
                page.attributes[:content_type] = content_type
              end
            end

            def set_fullpath_for(page, locale)
              slug = fullpath = page.attributes[:slug][locale].try(:dasherize)

              return if slug.blank?

              if depth(page) > 1
                base = parent_fullpath(page)
                fullpath = (fetch_localized_fullpath(base, locale) || base) + '/' + slug
              end

              set_localized_fullpath(page._fullpath, fullpath, locale)
              page.attributes[:fullpath][locale] = fullpath
            end

            def depth(page)
              page._fullpath.split('/').size
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
