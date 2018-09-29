module Locomotive::Steam
  class Section

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        slug:       nil,
        template:   nil,
        source:     nil,
        definition: nil
      }.merge(attributes))
    end

    def source
      self[:template]
    end

    def type
      self[:slug]
    end

  end
end
