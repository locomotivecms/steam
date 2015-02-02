module Locomotive
  module Steam
    module Services

      class CsrfProtection < Struct.new(:enabled, :field, :token)

        def enabled?
          !!enabled
        end

      end

    end
  end
end
