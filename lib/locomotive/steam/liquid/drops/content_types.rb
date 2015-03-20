module Locomotive
  module Steam
    module Liquid
      module Drops
        class ContentTypes < ::Liquid::Drop

          def before_method(meth)
            repository = @context.registers[:services].repositories.content_type

            if content_type = repository.by_slug(meth.to_s)
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
