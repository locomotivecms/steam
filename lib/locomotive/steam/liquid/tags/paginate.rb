module Locomotive
  module Steam
    module Liquid
      module Tags

        # Paginate a collection (array or from a DB).
        #
        # Usage:
        #
        # {% paginate contents.projects by 5 %}
        #   {% for project in paginate.collection %}
        #     {{ project.name }}
        #   {% endfor %}
        #  {% endpaginate %}
        #
        class Paginate < ::Liquid::Block

          Syntax = /(#{::Liquid::QuotedFragment}+)\s+by\s+([0-9]+)/o

          def initialize(tag_name, markup, options)
            if markup =~ Syntax
              @collection_name  = $1
              @per_page         = $2.to_i
              @paginate_options = {}
              markup.scan(::Liquid::TagAttributes) { |key, value| @paginate_options[key.to_sym] = value.gsub(/^'/, '').gsub(/'$/, '') }
            else
              raise ::Liquid::SyntaxError.new('Valid syntax: paginate <collection> by <number>')
            end

            super
          end

          def render(context)
            context.stack do
              pagination = context['paginate'] = paginate_collection(context)

              path = sanitize_path(context['fullpath'])

              build_next_previous_links(pagination, path)

              if pagination['total_pages'] > 1
                build_parts(pagination, path)
              end

              super
            end
          end

          private

          # Paginate the collection and returns a pagination
          # object storing all the information about the paginated
          # collection.
          #
          def paginate_collection(context)
            collection    = context[@collection_name]
            current_page  = context['current_page']

            raise ::Liquid::ArgumentError.new("Cannot paginate '#{@collection_name}'. Not found.") if collection.nil?

            pager = Locomotive::Steam::Models::Pager.new(collection, current_page, @per_page)

            # make sure the pagination object is a hash with strings as keys (and not symbol)
            HashConverter.to_string(pager.to_liquid).tap do |_pagination|
              _pagination['parts'] = []
            end
          end

          def build_next_previous_links(pagination, path)
            current_page = pagination['current_page']

            if pagination['previous_page']
              pagination['previous']= link(I18n.t('pagination.previous'), current_page - 1, path)
            end

            if pagination['next_page']
              pagination['next'] = link(I18n.t('pagination.next'), current_page + 1, path)
            end
          end

          def build_parts(pagination, path)
            hellip_break  = false

            1.upto(pagination['total_pages']) do |page|
              hellip_break = _build_parts(pagination, path, page, hellip_break)
            end
          end

          def _build_parts(pagination, path, page, hellip_break)
            if pagination['current_page'] == page
              pagination['parts'] << no_link(page)
            elsif is_page_a_bound?(pagination, page)
              pagination['parts'] << link(page, page, path)
            elsif is_page_inside_window?(pagination, page)
              pagination['parts'] << no_link('&hellip;') unless hellip_break
              return true
            else
              pagination['parts'] << link(page, page, path)
            end

            false
          end

          def sanitize_path(path)
            _path = path.gsub(/page=[0-9]+&?/, '').gsub(/_pjax=true&?/, '')
            _path = _path.slice(0..-2) if _path.last == '?' || _path.last == '&'
            _path
          end

          def is_page_inside_window?(pagination, page)
            page <= pagination['current_page'] - window_size or page >= pagination['current_page'] + window_size
          end

          def is_page_a_bound?(pagination, page)
            page == 1 || page == pagination['total_pages']
          end

          def window_size
            @window_size ||= @paginate_options[:window_size] ? @paginate_options[:window_size].to_i : 3
          end

          def no_link(title)
            { 'title' => title, 'is_link' => false, 'hellip_break' => title == '&hellip;' }
          end

          def link(title, page, path)
            _path = %(#{path}#{path.include?('?') ? '&' : '?'}page=#{page})
            { 'title' => title, 'url' => _path, 'is_link' => true }
          end
        end

        ::Liquid::Template.register_tag('paginate'.freeze, Paginate)
      end

    end
  end
end
