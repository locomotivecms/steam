module Locomotive
  module Steam
    module Liquid
      module Drops
        class ContentTypes < ::Liquid::Drop

          def before_method(meth)
            if content_type = fetch_content_type(meth.to_s)
              ContentEntryCollection.new(content_type)
            else
              nil
            end
          end

          private

          def repository
            @context.registers[:services].repositories.content_type
          end

          def fetch_content_type(slug)
            @content_type_map ||= {}

            if !@content_type_map.include?(slug)
              @content_type_map[slug] = repository.by_slug(slug)
            end

            @content_type_map[slug]
          end

        end

      end
    end
  end
end
