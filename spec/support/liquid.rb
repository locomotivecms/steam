def render_template(source, context = nil, options = {})
  context ||= ::Liquid::Context.new
  context.exception_handler = ->(e) { true }
  ::Liquid::Template.parse(source, options).render(context)
end

def parse_template(source, options = nil)
  ::Liquid::Template.parse(source, options || {})
end

module Liquid
  class SimpleEventsListener
    def initialize
      ActiveSupport::Notifications.subscribe(/^steam\.parse\.editable/) do |name, start, finish, id, payload|
        emit(name, payload)
      end
    end
    def emit(name, options = {})
      (@stack ||= []) << [name, options]
    end
    def event_names
      (@stack || []).map { |(name, _)| name }
    end
    def events
      @stack || []
    end
  end
end

def liquid_instance_double(doubled_class, stubs)
  instance_double(doubled_class, stubs).tap do |double|
    allow(double).to receive(:to_liquid).and_return(double)
  end
end
