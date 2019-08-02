require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::Section do

  let(:assigns) { {} }
  let(:context) { ::Liquid::Context.new(assigns, {}, {}) }

  subject { render_template(source, context).strip }

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

  describe 'link field' do

    let(:source) { <<-EOF
      {% if link is present %}
        We've got a link!
      {% else %}
        Nope
      {% endif %}
  EOF
    }

    let(:assigns) { { 'link' => Locomotive::Steam::Liquid::Drops::SectionUrlField.new(url) } }

    context 'the link is nil' do

      let(:url) { nil }
      it { is_expected.to eq 'Nope' }

    end

    context 'the link is an empty string' do

      let(:url) { '' }
      it { is_expected.to eq 'Nope' }

    end

    context 'the link is an url' do

      let(:url) { 'https://www.locomotivecms.com' }
      it { is_expected.to eq "We've got a link!" }

    end

  end

end
