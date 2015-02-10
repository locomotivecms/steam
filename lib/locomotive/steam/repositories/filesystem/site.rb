require_relative 'models/site'

module Locomotive
  module Steam
    module Repositories
      module Filesystem

        class Site

          def by_host(host, options = {})
            loader      = MemoryAdapter::YAMLLoader.instance(options[:path])
            attributes  = loader.simple('config/site.yml')

            Models::Site.new(attributes).tap do |site|
              loader.default_locale = site.default_locale.to_sym
            end
          end

        end

      end
    end
  end
end
