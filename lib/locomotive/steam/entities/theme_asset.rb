module Locomotive::Steam

  class ThemeAsset

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        local_path: nil,
        checksum:   nil
      }.merge(attributes))
    end


  end

end
