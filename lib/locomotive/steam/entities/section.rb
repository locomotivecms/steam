module Locomotive::Steam

  class Section

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        template: nil,
        source:   nil,
        definition: nil
      }.merge(attributes))
    end

    def source
      self[:template]
    end

  end

end
