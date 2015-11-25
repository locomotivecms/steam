require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::Page do

  describe '#editable_elements' do

    let(:source) { <<-EOF
  <h1>{{ page.editable_elements.content.header.title }}</h1>
  {% block content %}
    {% block header %}
      {% editable_text title %}Hello world{% endeditable_text %}
    {% endblock %}
  {% endblock %}
  EOF
    }

    let(:elements)  { nil }
    let(:page)      { instance_double('Page', localized_attributes: [], fullpath: 'index', editable_elements: elements) }
    let(:drop)      { described_class.new(page) }
    let(:services)  { Locomotive::Steam::Services.build_instance }
    let(:context)   { ::Liquid::Context.new({ 'page' => drop }, {}, { page: page, services: services }, true) }

    subject { render_template(source, context, { page: page, default_editable_content: {} }) }

    it { is_expected.to match /<h1>Hello world<\/h1>/ }

    context 'content updated by an user' do

      let(:elements) { [instance_double('EditableText', block: 'content/header', slug: 'title', content: 'Bonjour le monde', :base_url= => nil, localized_attributes: [], default_content?: false, format: 'raw')] }

      before do
        services.locale = :en
        services.repositories.current_site = instance_double('Site', default_locale: :en)
        allow(services.repositories.page).to receive(:editable_elements_of).and_return(elements)
      end

      it { is_expected.to match /<h1>Bonjour le monde<\/h1>/ }

    end

  end

end
