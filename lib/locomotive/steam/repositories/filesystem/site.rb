module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Site < Struct.new(:loader)

          def by_host(host, options = {})
            Filesystem::Models::Site.new(loader.attributes).tap do |site|
              loader.default_locale = site.default_locale.to_sym
            end
          end

        end

      end
    end
  end
end
