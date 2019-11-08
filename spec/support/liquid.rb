def render_template(source, context = nil, options = {})
  context ||= ::Liquid::Context.new
  context.exception_renderer = ->(e) do
    # puts e.message # UN-COMMENT IT FOR DEBUGGING
    raise e
  end
  Locomotive::Steam::Liquid::Template.parse(source, options).render(context)
end

def parse_template(source, options = nil)
  ::Liquid::Template.parse(source, options || {})
end

module Liquid

  class TestDrop < Liquid::Drop
    def initialize(source)
      @_source = source.with_indifferent_access
    end

    def liquid_method_missing(meth)
      @_source[meth.to_sym]
    end

    def as_json(options = nil)
      @_source.as_json(options)
    end
  end

  class SimpleEventsListener
    def initialize
      ActiveSupport::Notifications.subscribe(/^steam\.parse\./) do |name, start, finish, id, payload|
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

  class LayoutFileSystem
    def read_template_file(template_path, _)
      case template_path
      when "base"
        "<body>base</body>"

      when "inherited"
        "{% extends base %}"

      when "page_with_title"
        "<body><h1>{% block title %}Hello{% endblock %}</h1><p>Lorem ipsum</p></body>"

      when "product"
        "<body><h1>Our product: {{ name }}</h1>{% block info %}{% endblock %}</body>"

      when "product_with_warranty"
        "{% extends product %}{% block info %}<p>mandatory warranty</p>{% endblock %}"

      when "product_with_static_price"
        "{% extends product %}{% block info %}<h2>Some info</h2>{% block price %}<p>$42.00</p>{% endblock %}{% endblock %}"

      else
        template_path
      end
    end
  end
end

def liquid_instance_double(doubled_class, stubs)
  instance_double(doubled_class, stubs).tap do |double|
    allow(double).to receive(:to_liquid).and_return(double)
  end
end
