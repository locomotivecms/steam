require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::PageNotFound do

  let(:template)  { '{% render_page_not_found %}' }
  let(:context)   { ::Liquid::Context.new({}, {}, {}) }

  subject { render_template(template, context) }

  it 'raises an exception' do
    expect { subject }.to raise_error(Locomotive::Steam::PageNotFoundException)
  end

end
