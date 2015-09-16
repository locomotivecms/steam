module Locomotive
  module Steam

    class CsrfProtectionService

      attr_accessor_initialize :enabled, :field, :token

      def enabled?
        !!enabled
      end

    end

  end
end
