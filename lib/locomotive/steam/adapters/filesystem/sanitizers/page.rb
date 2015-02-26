module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class Page

          include Adapters::Filesystem::Sanitizer

          def setup(scope)
            super.tap do
              @ids, @parent_ids = {}, {}
              @content_types    = {}
              @localized = locales.inject({}) { |m, l| m[l] = {}; m }
            end
          end

          def apply_to_entity(entity)
            entity[:site_id] = scope.site._id if scope.site

            record_id(entity) # required to get the parent_id

            locales.each do |locale|
              set_default_redirect_type(entity, locale)
              modify_if_templatized(entity, locale)
            end
          end

          def apply_to_dataset(dataset)
            sorted_collection(dataset.records.values).each do |page|
              locales.each do |locale|
                # the following method needs to be called first
                set_fullpath_for(page, locale)

                set_parent_id(page)
                use_default_locale_template_path(page, locale)
              end

              modify_if_nested_templatized(page)
            end
          end

          # when this is called, the @ids hash has been populated completely
          def set_parent_id(page)
            parent_key = parent_fullpath(page)

            page[:parent_ids] = @parent_ids[parent_key] || []
            page[:parent_id]  = @ids[parent_key]

            @parent_ids[page._fullpath] = page.parent_ids + [page._id]
          end

          # If the page does not have a template in a locale
          # then use the template of the default locale
          #
          def use_default_locale_template_path(page, locale)
            paths = page.template_path

            if paths[locale] == false
              paths[locale] = paths[default_locale]
            end
          end

          def set_default_redirect_type(page, locale)
            if page.redirect_url[locale]
              page.attributes[:redirect_type] ||= 301
            end
          end

          def modify_if_nested_templatized(page)
            if content_type = fetch_content_type(parent_fullpath(page))
              # not a templatized page but it becomes one because
              # its parent is one of them
              page[:content_type] = content_type
            end
          end

          def set_fullpath_for(page, locale)
            page._fullpath ||= page.attributes.delete(:_fullpath)

            slug = fullpath = page.slug[locale].try(page.templatized? ? :to_s : :dasherize)

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

            if page.depth == 1 && system_pages?(page)
              page.depth = 0
            end

            page.depth
          end

          def system_pages?(page)
            %w(index 404).include?(page.slug.values.compact.first)
          end

          def sorted_collection(collection)
            collection.sort_by { |page| depth(page) }
          end

          def parent_fullpath(page)
            return nil if page._fullpath == 'index'
            path = page._fullpath.split('/')[0..-2].join('/')
            path.blank? ? 'index' : path
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

          def record_id(entity)
            @ids[entity[:_fullpath]] = entity._id
          end

          def modify_if_templatized(page, locale)
            if page.templatized?
              page[:slug][locale] = Locomotive::Steam::WILDCARD
              set_content_type(page[:_fullpath], page.content_type)
            end
          end

        end

      end
    end
  end
end
