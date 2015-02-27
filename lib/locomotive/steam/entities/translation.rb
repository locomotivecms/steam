module Locomotive::Steam

  class Translation

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        values: {}
      }.merge(attributes))
    end

  end

end
