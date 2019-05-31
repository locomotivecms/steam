module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class Page

          include Adapters::Filesystem::Sanitizer

          def setup(scope)
            super.tap do
              @ids, @parent_ids, @templatized_ids = {}, {}, {}
              @localized = locales.inject({}) { |m, l| m[l] = {}; m }
            end
          end

          def apply_to_entity(entity)
            super

            record_id(entity) # required to get the parent_id

            locales.each do |locale|
              set_automatic_translations(entity, locale)
              set_default_redirect_type(entity, locale)
            end

            check_and_mark_as_templatized(entity)
          end

          def apply_to_dataset(dataset)
            sorted_collection(dataset.records.values).each do |page|
              locales.each do |locale|
                set_parent_id(page)

                modify_if_parent_templatized(page, locale)

                # the following method needs to be called first
                set_fullpath_for(page, locale)

                use_default_locale_template_path(page, locale)

                # make sure we'll deal with a Hash and not a string
                transform_sections_content(page, locale)
              end
            end
          end

          # when this is called, the @ids hash has been populated completely
          def set_parent_id(page)
            page._fullpath ||= page.attributes.delete(:_fullpath)

            return if page._fullpath == '404'

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

          def set_fullpath_for(page, locale)
            slug = fullpath = page.slug[locale].try(:to_s)

            return if slug.blank?

            if page.depth > 1
              base = parent_fullpath(page)
              fullpath = (fetch_localized_fullpath(base, locale) || base) + '/' + slug
            end

            set_localized_fullpath(page._fullpath, fullpath, locale)
            page[:fullpath][locale] = fullpath
          end

          def set_automatic_translations(page, locale)
            return if locale == default_locale

            if page[:template_path][locale].blank?
              %i(
                title slug fullpath template_path redirect_url
                sections_content sections_dropzone_content
                seo_title meta_description meta_keywords
              ).each do |name|
                page[name][locale] ||= page[name][default_locale]
              end
            end
          end

          def depth(page)
            return page.depth if page.depth

            page.depth = page[:_fullpath].split('/').size

            if system_pages?(page)
              page.depth = 0
            end

            page.depth
          end

          def system_pages?(page)
            page.depth == 1 &&
            %w(index 404).include?(page.slug.values.compact.first)
          end

          def sorted_collection(collection)
            collection.sort_by { |page| depth(page) }
          end

          def parent_fullpath(page)
            return nil if page._fullpath == 'index' || page._fullpath == '404'
            path = page._fullpath.split('/')[0..-2].join('/')
            path.blank? ? 'index' : path
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

          def check_and_mark_as_templatized(page)
            if content_type = page[:content_type]
              mark_as_templatized(page, content_type)
            end
          end

          def mark_as_templatized(page, content_type)
            @templatized_ids[page._id]  = content_type
            page[:templatized]          = true
            page[:target_klass_name]    = "Locomotive::ContentEntry#{content_type}"
          end

          def transform_sections_content(page, locale)
            [:sections_dropzone_content, :sections_content].each do |name|
              if content = page[name][locale]
                return unless content.is_a?(String)

                begin
                  page[name][locale] = Hjson.parse(content)
                rescue Exception => e
                  raise Locomotive::Steam::JsonParsingError.new(e, page.template_path[locale], content)
                end
              end
            end
          end

          def modify_if_parent_templatized(page, locale)
            parent_templatized = @templatized_ids[page.parent_id]

            if page[:templatized]
              page[:slug][locale] = Locomotive::Steam::WILDCARD unless parent_templatized
            elsif parent_templatized
              mark_as_templatized(page, parent_templatized)
            end
          end

        end

      end
    end
  end
end
