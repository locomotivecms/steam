require 'spec_helper'

describe Locomotive::Steam::ActionService do

  let(:site_hash)      { { 'name' => 'Acme Corp' } }
  let(:site)           { instance_double('Site', as_json: site_hash ) }
  let(:email_service)  { instance_double('EmailService') }
  let(:entry_service)  { instance_double('ContentService') }
  let(:api_service)    { instance_double('ExternalAPIService') }
  let(:redirection_service) { instance_double('PageRedirectionService') }
  let(:cookie_service) { instance_double('CookieService') }
  let(:service)        { described_class.new(site, email_service, content_entry: entry_service, api: api_service, redirection: redirection_service, cookie: cookie_service) }

  describe '#run' do

    let(:script)  { 'return 1 + 1;' }
    let(:params)  { {} }
    let(:assigns) { {} }
    let(:session) { {} }
    let(:cookies) { {} }
    let(:context) { ::Liquid::Context.new(assigns, {}, { session: session, cookies: cookies }) }

    subject { service.run(script, params, context) }

    it { is_expected.to eq 2.0 }

    describe 'deal with dates (since EPOCH in milliseconds) from a param' do

      let(:params) { { 'api' => { 'title' => 'Hello world', 'sent_at' => 1536598528930 } } }
      let(:script) { "return params.api.sent_at;" }

      it { is_expected.to eq 1536598528930 }

    end

    describe 'deal with exceptions' do

      context 'wrong syntax' do

        let(:script) { 'a +/ b * var;' }

        it 'raises a meaningful exception' do
          expect { subject }.to raise_error(Locomotive::Steam::ActionError, "Action error - unterminated regexp (line 2)")
        end

      end

      context 'other error' do

        let(:script) { 'a.b' }

        it 'raises a meaningful exception' do
          expect { subject }.to raise_error(Locomotive::Steam::ActionError, "Action error - identifier 'a' undefined")
        end

      end

    end

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

      describe 'getCookiesProp' do

        let(:script) { "return getCookiesProp('name');" }

        it 'should read in the cookie name and return John' do
          expect(cookie_service).to receive(:get).with('name').and_return('John')
          is_expected.to eq('John')
        end

      end

      describe 'setCookiesProp' do

        let(:script) { "return setCookiesProp('done', {'value': true});" }

        it 'should set the cookie done with the value true' do
          expect(cookie_service).to receive(:set).with('done', {'value' => true})
          is_expected.to eq(nil)
        end

      end

      describe 'log' do

        let(:script) { "log('Hello world!');" }

        it 'should call the internal logger to output the log message' do
          expect(Locomotive::Common::Logger).to receive(:info).with('Hello world!')
          is_expected.to eq(nil)
        end

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

      describe 'callAPI' do

        let(:script) { "callAPI('POST', 'https://api.stripe.com/v1/charges', { username: 'abcdefghij', data: { token: '123456789' } })" }

        it 'forwards the action to the external api service' do
          expect(api_service).to receive(:consume).with(
            'https://api.stripe.com/v1/charges', {
              method: 'POST',
              username: 'abcdefghij',
              data: {
                token: '123456789'
              }
            }, true
          )
          subject
        end

      end

      describe 'redirectTo' do

        let(:script) { "redirectTo('about-us');" }

        it 'stops the rendering process and redirects the user to another page' do
          expect(redirection_service).to receive(:redirect_to).with('about-us', nil).and_raise(Locomotive::Steam::RedirectionException.new('/about-us'))
          expect { subject }.to raise_exception(Locomotive::Steam::RedirectionException, 'Redirect to /about-us (302)')
        end

      end

    end

  end

end
