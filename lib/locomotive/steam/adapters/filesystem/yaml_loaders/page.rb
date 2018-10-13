require 'oj'

module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class Page

            include Adapters::Filesystem::YAMLLoader

            # Basically Load all the pages from both the app/views/pages and data/<env>/pages folders
            #
            # The process to load locally all the pages is pretty complex. Of course, it handles localized pages.
            # It involves 2 main steps.
            #
            # 1/ load all the pages/layouts under app/views/pages. Because of legacy support,
            # we still grab the data from the YAML header.
            #
            # 2/ load the localized content from the data/<env>/pages folder. The content is fetched
            # from the Wagon sync command. 2 kind of pages are stored in this folder:
            #   - pages with a handle property not null. We call them core pages. They are not aimed
            #     to be deleted. When found, we merge their content with the original page found by process #1
            #   - pages without a handle and created from a layout. These pages don't own a liquid template.
            #     We just use the liquid template of the layout they belong to.
            #
            def load(scope)
              super

              @pages_by_fullpath  = {}
              @pages_by_handle    = {}

              # step #1 (cf description of the method)
              load_tree

              # step #2 (cf description of the method)
              load_data

              @pages_by_fullpath.values
            end

            private

            def load_tree
              # load the core pages and layouts from the app/views/pages folder
              each_file do |filepath, fullpath, locale|
                if leaf = @pages_by_fullpath[fullpath]
                  update(leaf, filepath, fullpath, locale)
                else
                  leaf = build(filepath, fullpath, locale)
                end

                @pages_by_fullpath[fullpath]    = leaf
                @pages_by_handle[leaf[:handle]] = leaf if leaf[:handle].present?
              end

              each_directory do |filepath, fullpath, locale|
                @pages_by_fullpath[fullpath] ||= build(filepath, fullpath, locale)
              end
            end

            def load_data
              datapath = File.join(site_path, 'data', env.to_s, 'pages')

              Dir.glob(File.join(datapath, '**', '*.json')).each do |filepath|
                filepath  =~ /#{data_path}\/([a-z]+)\//
                locale    = locales.include?($1) ? $1 : default_locale
                data      = JSON.parse(File.read(filepath))

                if data['handle'].present? # yeah, core page found!
                  attributes = @pages_by_handle[data['handle']]

                  next if attributes.nil? # shouldn't happen (undeleted page? local files out of date?)

                  # this is super important to handle correctly url type settings in sections
                  attributes[:_id] = data['id']

                  # set the localized attributes
                  %i(
                    title slug redirect_url seo_title meta_description meta_keywords
                    sections_content sections_dropzone_content editable_elements
                  ).each do |name|
                    next if (value = data[name.to_s]).nil?

                    if name == :editable_elements
                      update_editable_elements(attributes, value, locale)
                    else
                      attributes[name] = { locale => value }
                    end
                  end
                else
                  puts data.inspect
                  raise "TODO #{data['title']}"
                  # raw_template: {% extends <layout> %}....
                  # TO BE TESTED WITH ANAE's site
                end
              end
            end

            # # First, load the
            # def build_from_data(pages)
            #   datapath = File.join(site_path, 'data', env.to_s, 'pages')

            #   # load pages in the default locale
            #   Dir.glob(File.join(datapath, '**', '*.json')).each do |filepath|
            #     filepath =~ /#{data_path}\/([a-z]+)\//

            #     next if (locales - [default_locale]).include?($1)

            #     relative_path = get_relative_path(filepath)
            #     fullpath      = relative_path.split('.')[0]
            #     slug          = fullpath.split('/').last
            #     data          = JSON.parse(File.read(filepath))

            #     attributes = {
            #       _id:            data['id'],
            #       title:          { default_locale => data['title'] },
            #       slug:           { default_locale => data['slug'] || slug },
            #       handle:         data['handle'],
            #       # TODO: no need to get the following 2 attributes
            #       # template_path:  { default_locale => File.join(path, "#{fullpath}.liquid") },
            #       # _fullpath:      fullpath
            #     }

            #     %i(
            #       title slug redirect_url seo_title meta_description meta_keywords
            #       sections_content sections_dropzone_content editable_elements
            #     ).each do |name|
            #       value = data[name.to_s]

            #       next if value.nil?

            #       if name == :editable_elements
            #         update_editable_elements(attributes, value, default_locale)
            #       else
            #         attributes[name] = { default_locale => value }
            #       end
            #     end

            #     puts attributes.inspect

            #     raise 'TODO'
            #   end

            #   # TODO: in the other locales
            # end

            def build(filepath, fullpath, locale)
              slug            = fullpath.split('/').last
              attributes      = get_attributes(filepath, fullpath)

              # use first the attributes of the liquid template
              _attributes = {
                title:              { locale => attributes.delete(:title) || (default_locale == locale ? slug.humanize : nil) },
                slug:               { locale => attributes.delete(:slug) || slug.dasherize },
                template_path:      { locale => template_path(filepath, attributes, locale) },
                editable_elements:  build_editable_elements(attributes.delete(:editable_elements), locale),
                _fullpath:          fullpath
              }

              %i(
                redirect_url seo_title meta_description meta_keywords
                sections_content sections_dropzone_content
              ).each do |name|
                _attributes[name] = { locale => attributes.delete(name) }
              end

              _attributes.merge!(attributes)
            end

            # def append_data(fullpath, attributes)
            #   data = get_data(fullpath)

            #   return attributes if data.keys.compact.blank?

            #   %i(
            #     title slug redirect_url seo_title meta_description meta_keywords
            #     sections_content sections_dropzone_content editable_elements
            #   ).each do |name|
            #     data.each do |locale, localized_data|
            #       value = localized_data[name.to_s]

            #       next if value.nil?

            #       if name == :editable_elements
            #         update_editable_elements(attributes, value, locale)
            #       else
            #         attributes[name][locale] = value || attributes[name][locale]
            #       end
            #     end
            #   end

            #   _attributes[:_id] = data[default_locale]['id']
            # end

            def update(leaf, filepath, fullpath, locale)
              slug            = fullpath.split('/').last
              attributes      = get_attributes(filepath, fullpath)

              leaf[:title][locale]              ||= attributes.delete(:title) || slug.humanize
              leaf[:slug][locale]               ||= attributes.delete(:slug) || slug.dasherize
              leaf[:template_path][locale]      = template_path(filepath, attributes, locale)

              update_editable_elements(leaf, attributes.delete(:editable_elements), locale)

              %i(
                redirect_url seo_title meta_description meta_keywords
                sections_content sections_dropzone_content
              ).each do |name|
                leaf[name][locale] ||= attributes.delete(name)
              end

              leaf.merge!(attributes)
            end

            def get_attributes(filepath, fullpath)
              if File.directory?(filepath)
                {
                  title:          File.basename(filepath).humanize,
                  listed:         false,
                  published:      false
                }
              else
                _load(filepath, true) do |attributes, template|
                  # make sure index/404 are the slugs of the index/404 pages
                  attributes.delete(:slug) if %w(index 404).include?(fullpath)

                  # trick to use the template of the default locale (if available)
                  attributes[:template_path] = false if template.blank?

                  # page under layouts/ should be treated differently
                  set_layout_attributes(attributes) if fullpath.split('/').first == 'layouts'
                end
              end
            end

            def each_file(&block)
              Dir.glob(File.join(path, '**', '*')).each do |filepath|
                next unless is_liquid_file?(filepath)

                relative_path = get_relative_path(filepath)

                fullpath, extension_or_locale = relative_path.split('.')[0..1]

                locale = template_extensions.include?(extension_or_locale) ? default_locale : extension_or_locale

                yield(filepath, fullpath, locale.to_sym)
              end
            end

            def each_directory(&block)
              Dir.glob(File.join(path, '**', '*')).each do |filepath|
                next unless File.directory?(filepath)

                fullpath = get_relative_path(filepath)

                yield(filepath, fullpath, default_locale.to_sym)
              end
            end

            def is_liquid_file?(filepath)
              filepath =~ /\.(#{template_extensions.join('|')})$/
            end

            def template_path(filepath, attributes, locale)
              if File.directory?(filepath) || (attributes.delete(:template_path) == false && locale != default_locale)
                false
              else
                filepath
              end
            end

            def get_relative_path(filepath)
              filepath.gsub(path, '').gsub(/^\//, '')
            end

            def build_editable_elements(list, locale)
              return [] if list.blank?

              list.map do |name, content|
                build_editable_element(name, content, locale)
              end
            end

            def update_editable_elements(leaf, list, locale)
              return if list.blank?

              list.each do |name, content|
                if el = find_editable_element(leaf, name)
                  el[:content][locale] ||= content
                else
                  leaf[:editable_elements] << build_editable_element(name, content, locale)
                end
              end
            end

            def find_editable_element(leaf, name)
              leaf[:editable_elements].find do |el|
                [el[:block], el[:slug]].join('/') == name.to_s
              end
            end

            def build_editable_element(name, content, locale)
              segments    = name.to_s.split('/')
              block, slug = segments[0..-2].join('/'), segments.last
              block       = nil if block.blank?

              { block: block, slug: slug, content: { locale => content } }
            end

            def set_layout_attributes(attributes)
              attributes[:is_layout]  = true if attributes[:is_layout].nil?
              attributes[:listed]     = false
              attributes[:published]  = false
            end

            def data_path
              File.join(self.site_path, 'data', env, 'pages')
            end

            def path
              @path ||= File.join(site_path, 'app', 'views', 'pages')
            end

            # def get_data(fullpath)
            #   locales.inject({}) do |memo, locale|
            #     filepath = File.join(site_path, 'data', env.to_s, 'pages', default_locale == locale ? '' : locale.to_s, fullpath + '.json')

            #     memo[locale] = if File.exists?(filepath)
            #       JSON.parse(File.read(filepath))
            #     else
            #       {}
            #     end

            #     memo
            #   end
            # end

          end

        end
      end
    end
  end
end
