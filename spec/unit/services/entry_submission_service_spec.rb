require 'spec_helper'

describe Locomotive::Steam::EntrySubmissionService do

  let(:entry_service) { instance_double('ContentEntryService') }
  let(:service)       { described_class.new(entry_service) }

  describe '#find' do

    subject { service.find('messages', '42') }

    it { expect(entry_service).to receive(:find).with('messages', '42'); subject }

  end

  describe '#submit' do

    let(:content_type) { instance_double('ContentType', public_submission_enabled: public_submission_enabled) }

    before { allow(entry_service).to receive(:get_type).with('messages').and_return(content_type) }

    subject { service.submit('messages', { name: 'John Doe', body: 'Lorem ipsum' }) }

    context "the content type doesn't exist" do

      let(:public_submission_enabled) { true }
      let(:content_type) { nil }
      it { is_expected.to eq nil }

    end

    context "the content type exists but it's not enabled for public submission" do

      let(:public_submission_enabled) { false }
      it { is_expected.to eq nil }

    end

    context 'the content type exists and is enabled for public submission' do

      let(:public_submission_enabled) { true }
      it 'calls the entry service to create the message' do
        expect(entry_service).to receive(:create).with(content_type, { name: 'John Doe', body: 'Lorem ipsum' })
        subject
      end

    end

  end

  describe '#to_json' do

    let(:entry) { instance_double('Entry', to_json: "{'name':'John'}") }

    subject { service.to_json(entry) }

    it { is_expected.to eq("{'name':'John'}") }

    context 'entry is nil' do

      let(:entry) { nil }
      it { is_expected.to eq nil }

    end

  end

end
