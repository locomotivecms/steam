module Locomotive
  module Steam

    class CsrfProtectionService < Struct.new(:enabled, :field, :token)

      def enabled?
        !!enabled
      end

    end

  end
end
