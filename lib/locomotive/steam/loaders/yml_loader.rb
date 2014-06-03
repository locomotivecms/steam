require_relative 'yml/site_loader'
require_relative 'yml/pages_loader'
require_relative 'yml/utils/yaml_front_matters_template'

module Locomotive
  module Steam
    module Loader
      class YmlLoader

        MODELS = %W[site]

        def initialize path, mapper
          @root_path, @mapper = path, mapper
        end

        def load!
          load_site!
          load_pages!
        end

        def load_site!
          Locomotive::Steam::Loader::Yml::SiteLoader.new(@root_path, @mapper).load!
        end

        def load_pages!
          Locomotive::Steam::Loader::Yml::PagesLoader.new(@root_path, @mapper).load!
        end

      end
    end
  end
end
