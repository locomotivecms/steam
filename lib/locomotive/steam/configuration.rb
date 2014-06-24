module Locomotive
  module Steam

    class Configuration
      attr_accessor :mode

      def initialize
        self.mode = :production
      end
    end

  end
end
