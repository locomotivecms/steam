module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Translation < Struct.new(:loader, :site)

          include Concerns::Queryable

          set_collection model: Filesystem::Models::Translation

          # Engine: site.translations.where(key: key).first
          def find(key)
            query { where(key: key) }.first
          end

        end

      end
    end
  end
end
