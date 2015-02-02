def render_template(template, context)
  ::Liquid::Template.parse(template).render(context)
end
