require 'spec_helper'

describe Locomotive::Steam::Liquid::FileSystem do

  let(:section_finder) { instance_double('SectionFinder') }
  let(:snippet_finder) { instance_double('SnippetFinder') }
  let(:instance) { described_class.new(section_finder: section_finder, snippet_finder: snippet_finder) }

  describe '#read_template_file' do

    let(:template_path) { nil }

    subject { instance.read_template_file(template_path) }

    context 'unknown type' do

      let(:template_path) { 'unknown_template' }

      it { expect { subject }.to raise_error('Liquid error: This liquid context does not allow unknown_template.') }

    end

  end

end
