module Locomotive
  module Steam
    module Liquid
      module Filters
        module Pagination

          # Render the navigation for a paginated collection
          def default_pagination(paginate, *args)
            return '' if paginate['parts'].empty?

            options = args_to_options(args)

            previous_link = default_pagination_next_or_previous_link(:previous, paginate, options, 'prev')
            next_link     = default_pagination_next_or_previous_link(:next, paginate, options, 'next')
            links         = default_pagination_links(paginate)

            %{<div class="pagination #{options[:css]}">
                #{previous_link}
                #{links}
                #{next_link}
              </div>}
          end

          private

          def default_pagination_links(paginate)
            paginate['parts'].map do |part|
              if part['is_link']
                "<a href=\"#{absolute_url(part['url'])}\">#{part['title']}</a>"
              elsif part['hellip_break']
                "<span class=\"gap\">#{part['title']}</span>"
              else
                "<span class=\"current\">#{part['title']}</span>"
              end
            end.join
          end

          def default_pagination_next_or_previous_link(type, paginate, options, css)
            label = options[:"#{type}_label"] || I18n.t("pagination.#{type}")

            if paginate[type.to_s].blank?
              "<span class=\"disabled #{css}_page\">#{label}</span>"
            else
              "<a href=\"#{absolute_url(paginate[type.to_s]['url'])}\" class=\"#{css}_page\">#{label}</a>"
            end
          end

        end

        ::Liquid::Template.register_filter(Pagination)

      end
    end
  end
end
