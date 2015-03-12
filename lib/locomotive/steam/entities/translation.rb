module Locomotive::Steam

  class Translation

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        values: {}
      }.merge(attributes))
    end

    def values
      self[:values]
    end

  end

end
