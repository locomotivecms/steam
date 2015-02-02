module Locomotive
  module Steam
    module Repositories

      class Translation < Struct.new(:site)

        def find(key)
          site.translations.where(key: input).first
        end

      end

    end
  end
end
