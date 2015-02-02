Dir[File.join(File.dirname(__FILE__), 'repositories', '*.rb')].each { |lib| require lib }

module Locomotive
  module Steam
    module Repositories

      def self.build_instance(site = nil)
        Registered.new(site)
      end

      class Registered < Struct.new(:current_site)

        include Morphine

        # default repositories
        register :site do
          Repositories::Site.new
        end

        register :theme_asset do
          Repositories::ThemeAsset.new(current_site)
        end

        register :translation do
          Repositories::Translation.new(current_site)
        end

      end

    end
  end
end
