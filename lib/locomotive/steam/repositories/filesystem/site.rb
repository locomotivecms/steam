module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Site < Struct.new(:loader)

          def by_host(host, options = {})
            Filesystem::Models::Site.new(loader.attributes)
          end

        end

      end
    end
  end
end
