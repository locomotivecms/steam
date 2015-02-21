module Locomotive::Steam

  class Page

    include Locomotive::Steam::Models::Entity

    attr_accessor :depth, :_fullpath, :content_entry

    def initialize(attributes)
      super({
        handle:             nil,
        listed:             false,
        published:          true,
        fullpath:           {},
        content_type:       nil,
        position:           99,
        template:           {},
        editable_elements:  {},
        redirect_url:       {}
      }.merge(attributes))
    end

    def listed?; !!listed; end
    def published?; !!published; end

    def templatized?
      !!content_type
    end

    def index?
      attributes[:fullpath].values.first == 'index'
    end

    def not_found?
      attributes[:fullpath].values.first == '404'
    end

    def to_liquid
      Steam::Liquid::Drops::Page.new(self)
    end

  end

end
