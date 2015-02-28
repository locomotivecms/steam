module Locomotive::Steam
  module Adapters
    module Filesystem
      module Sanitizers

        class ContentType

          include Adapters::Filesystem::Sanitizer

          def apply_to_entity(entity)
            super

            entity[:slug] = entity[:slug].to_s
          end

        end

      end
    end
  end
end
