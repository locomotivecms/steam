def render_template(template, context = nil)
  context ||= ::Liquid::Context.new
  context.exception_handler = ->(e) { true }
  ::Liquid::Template.parse(template).render(context)
end
