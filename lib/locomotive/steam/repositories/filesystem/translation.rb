module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Translation < Struct.new(:site)

          def find(key)
            # site.translations.where(key: input).first
            raise 'TODO find'
          end

        end

      end
    end
  end
end
