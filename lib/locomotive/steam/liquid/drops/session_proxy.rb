module Locomotive
  module Steam
    module Liquid
      module Drops

        class SessionProxy < ::Liquid::Drop

          def liquid_method_missing(meth)
            request = @context.registers[:request]
            request.session[meth.to_sym]
          end

        end

      end
    end
  end
end
