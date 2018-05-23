require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Section do

  let(:services)  { Locomotive::Steam::Services.build_instance(nil) }
  let(:finder)    { services.section_finder }
  let(:source)    { "Locomotive {% section header %}" }
  let(:context)   { ::Liquid::Context.new({}, {}, { services: services }) }

  before do
    allow(finder).to receive(:find).and_return(section)
  end

  describe 'rendering' do

    subject { render_template(source, context) }

    shared_examples "works normally" do
      specify { is_expected.to eq 'Locomotive built by NoCoffee' }
    end

    context 'with simple example' do
      let(:section) { instance_double(
        'Section',
        liquid_source: 'built by NoCoffee',
        definition: {
          default: 'some default JSON'
        }
      )}
      
      it_behaves_like 'works normally'
    end
    
    context 'with empty definition' do
      let(:section) { instance_double(
        'Section',
        liquid_source: 'built by NoCoffee',
        definition: {}
      )}
      it_behaves_like 'works normally'
    end


    context 'rendering error (action) found in the section' do
      let(:section) { instance_double(
        'section',
        liquid_source: '{% action "Hello world" %}a.b(+}{% endaction %}',
        definition: {
          default: 'some default JSON'
        }
      )}

      it 'raises ParsingRenderingError' do
        expect { subject }.to raise_exception(Locomotive::Steam::ParsingRenderingError)
      end
    end
  end
end

