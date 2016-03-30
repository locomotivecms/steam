require 'spec_helper'

describe Locomotive::Steam::ActionService do

  let(:site_hash)     { { 'name' => 'Acme Corp' } }
  let(:site)          { instance_double('Site', as_json: site_hash ) }
  let(:email_service) { instance_double('EmailService') }
  let(:entry_service) { instance_double('ContentService') }
  let(:service)       { described_class.new(site, email_service, entry_service) }

  describe '#run' do

    let(:script)  { 'return 1 + 1;' }
    let(:params)  { {} }
    let(:assigns) { {} }
    let(:session) { {} }
    let(:context) { ::Liquid::Context.new(assigns, {}, { session: session }) }

    subject { service.run(script, params, context) }

    it { is_expected.to eq 2.0 }

    describe 'with params' do

      let(:params)  { { 'foo' => 'hello' } }
      let(:script)  { "return params.foo + ' world';" }

      it { is_expected.to eq 'hello world' }

      describe "messing with params" do

        let(:script)  { "params.foo += ' world!';" }

        it { is_expected.to eq nil }

        it "can't change a param value" do
          subject
          expect(params['foo']).to eq 'hello'
        end

      end

    end

    describe 'built-in functions / getters / setters' do

      describe 'site' do

        let(:script) { 'return "Name: " + site.name;' }

        it { is_expected.to eq 'Name: Acme Corp' }

      end

      describe 'getProp' do

        let(:assigns) { { 'name' => 'John' } }
        let(:script) { "return getProp('name');" }

        it { is_expected.to eq 'John' }

      end

      describe 'setProp' do

        let(:script) { "return setProp('done', true);" }

        it { subject; expect(context['done']).to eq true }

      end

      describe 'getSessionProp' do

        let(:session) { { name: 'John' } }
        let(:script) { "return getSessionProp('name');" }

        it { is_expected.to eq 'John' }

      end

      describe 'sendSessionProp' do

        let(:script) { "return setSessionProp('done', true);" }

        it { subject; expect(session[:done]).to eq true }

      end

      describe 'allEntries' do

        let(:now)     { Time.use_zone('America/Chicago') { Time.zone.local(2015, 'mar', 25, 10, 0) } }
        let(:assigns) { { 'now' => now } }
        let(:script) {
          <<-JS
            var entries = allEntries('bands', { 'created_at.lte': getProp('now'), published: true });
            var names = []

            for (var i = 0; i < entries.length; i++) {
              names.push(entries[i].name)
            }

            return names.join(', ')
          JS
        }

        before do
          expect(entry_service).to receive(:all).with('bands', { "created_at.lte" => "2015-03-25T10:00:00.000-05:00", "published" => true }, true).and_return([
            { 'name' => 'Pearl Jam' },
            { 'name' => 'Nirvana' },
            { 'name' => 'Soundgarden' }
          ])
        end

        it { is_expected.to eq('Pearl Jam, Nirvana, Soundgarden') }

      end

      describe 'findEntry' do

        let(:script) { "return findEntry('bands', '42').name;" }

        before do
          expect(entry_service).to receive(:find).with('bands', '42', true).and_return('name' => 'Pearl Jam')
        end

        it { is_expected.to eq('Pearl Jam') }

      end

      describe 'createEntry' do

        let(:script) { "return createEntry('bands', { name: 'Pearl Jam'}).name;" }

        before do
          expect(entry_service).to receive(:create).with('bands', { 'name' => 'Pearl Jam' }, true).and_return('name' => 'Pearl Jam')
        end

        it { is_expected.to eq('Pearl Jam') }

      end

      describe 'updateEntry' do

        let(:script) { "return updateEntry('bands', 'pearl-jam', { name: 'Pearl Jam'}).name;" }

        before do
          expect(entry_service).to receive(:update).with('bands', 'pearl-jam', { 'name' => 'Pearl Jam' }, true).and_return('name' => 'Pearl Jam')
        end

        it { is_expected.to eq('Pearl Jam') }

      end

      describe 'sendEmail' do

        let(:params) { { 'to' => 'estelle@locomotivecms.com' } }
        let(:script) { "sendEmail({ to: params.to, from: 'did@locomotivecms.com', subject: 'Happy Easter' })" }

        it 'forwards the action to the email service' do
          expect(email_service).to receive(:send_email).with({
            'to'      => 'estelle@locomotivecms.com',
            'from'    => 'did@locomotivecms.com',
            'subject' => 'Happy Easter' }, context)
          subject
        end

      end

    end

  end

end
