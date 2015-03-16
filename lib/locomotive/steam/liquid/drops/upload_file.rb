module Locomotive
  module Steam
    module Liquid
      module Drops
        class UploadedFile < Base

          delegate :size, :filename, to: :@_source

          def url
            asset_host.compute(@_source.url, @_source.updated_at.try(:to_i))
          end

          private

          def asset_host
            @context.registers[:services].asset_host
          end

        end
      end
    end
  end
end
