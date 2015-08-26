module Locomotive
  module Steam
    module Liquid
      module Drops
        class ContentTypes < ::Liquid::Drop

          def before_method(meth)
            fetch_content_type(meth.to_s)
          end

          private

          def repository
            @context.registers[:services].repositories.content_type
          end

          def fetch_content_type(slug)
            @content_type_map ||= {}

            if !@content_type_map.include?(slug)
              @content_type_map[slug] = _fetch_content_type(slug)
            end

            @content_type_map[slug]
          end

          def _fetch_content_type(slug)
            if content_type = repository.by_slug(slug)
              ContentEntryCollection.new(content_type)
            else
              nil
            end
          end

        end

      end
    end
  end
end
