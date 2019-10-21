module Locomotive
  module Steam
    module Liquid
      module Drops

        class Params < ::Liquid::Drop

          def initialize(params)
            @_params = params.stringify_keys
          end

          def liquid_method_missing(meth)
            Param.new(@_params[meth.to_s])
          end

          def unsafe
            @_params
          end

          def as_json
            @_params.as_json
          end

        end

        class Param < ::Liquid::Drop

          def initialize(param)
            @param = param
          end

          def html_safe
            @param
          end

          def to_liquid
            @param.is_a?(String) ? html_escape(@param) : @param
          end

          def to_s
            to_liquid.to_s
          end

          private

          def html_escape(string)
            string.blank? ? '' : CGI::escapeHTML(string)
          end

        end

      end
    end
  end
end
