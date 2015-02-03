def render_template(template, context = nil)
  context ||= ::Liquid::Context.new
  context.exception_handler = ->(e) { true }
  ::Liquid::Template.parse(template).render(context)
end

def parse_template(template, options = nil)
  ::Liquid::Template.parse(template, options || {})
end

module Liquid
  class SimpleEventsListener
    def emit(name, options = {})
      (@stack ||= []) << [name, options]
    end
    def event_names
      @stack.map { |(name, _)| name }
    end
    def events
      @stack
    end
  end
end
