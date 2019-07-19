require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Section do

  describe 'image_picker field' do

    let(:source) { <<-EOF
      {% if image is present %}
        We've got an image!
      {% else %}
        Nope
      {% endif %}
  EOF
    }

    let(:assigns)   { { 'image' => Locomotive::Steam::Liquid::Drops::SectionImagePickerField.new(image) } }
    let(:context)   { ::Liquid::Context.new(assigns, {}, {}) }

    subject { render_template(source, context).strip }

    context 'the image is nil' do

      let(:image) { nil }
      it { is_expected.to eq 'Nope' }

    end

    context 'the image is an empty string' do

      let(:image) { '' }
      it { is_expected.to eq 'Nope' }

    end

    context 'the image is an url' do

      let(:image) { 'https://cdn.somewhere.net/images/banner.png' }
      it { is_expected.to eq "We've got an image!" }

    end

  end

end
