module Locomotive::Steam

  class Snippet

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        template: nil,
        source:   nil
      }.merge(attributes))
    end

    def source
      self[:template]
    end

  end

end
