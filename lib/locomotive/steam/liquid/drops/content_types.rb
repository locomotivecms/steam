module Locomotive
  module Steam
    module Liquid
      module Drops
        class ContentTypes < ::Liquid::Drop

          def before_method(meth)
            
            # Find the object specified by the value of the variable pointed to by `meth`
            lookup = @context.find_variable(meth)
            if lookup && lookup.strip[0] == '~' # can't use strip! here because "".strip! returns nil.
              lookup.strip!

              # Find specific object
              entry_type, slug = lookup[1..-1].split('#')
              if content_type = fetch_content_type(entry_type)
                collection = ContentEntryCollection.new(content_type)
                collection.context = @context
                # TODO: cache this. Maybe implement context.set_variable
                return collection.find(slug)
              end
            end
            
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
