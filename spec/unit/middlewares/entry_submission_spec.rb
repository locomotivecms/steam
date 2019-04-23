require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/recaptcha'
require_relative '../../../lib/locomotive/steam/middlewares/entry_submission'

describe Locomotive::Steam::Middlewares::EntrySubmission do

  let(:app)                 { ->(env) { [200, env, ['app']] } }
  let(:site)                { instance_double('Site', default_locale: 'en', locales: ['en']) }
  let(:middleware)          { described_class.new(app) }
  let(:recaptcha_enabled)   { false }
  let(:recaptcha_valid)     { false }
  let(:content_type)        { instance_double('ContentType', :recaptcha_required? => recaptcha_enabled) }
  let(:service)             { instance_double('EntrySubmissionService') }
  let(:entry_service)       { instance_double('EntryService', get_type: content_type) }
  let(:recaptcha_service)   { instance_double('RecaptchaService', verify: recaptcha_valid) }
  let(:services)            { instance_double('Services', entry_submission: service, content_entry: entry_service, recaptcha: recaptcha_service, :locale= => 'en') }
  let(:session)             { {} }
  let(:method)              { 'POST' }
  let(:errors)              { instance_double('Error', empty?: false) }
  let(:entry)               { instance_double('Entry', errors: errors, content_type_slug: 'contacts') }
  let(:form)                { { content_type_slug: 'contacts', content: { email: 'john@doe.net' } } }
  let(:rack_env)            { build_env }

  before do
    allow_any_instance_of(described_class).to receive(:csrf_field).and_return('csrf_field')
    allow(service).to receive(:submit).with('contacts', { email: 'john@doe.net' }).and_return(entry)
    allow(entry_service).to receive(:build).with('contacts', { email: 'john@doe.net' }).and_return(entry)
  end

  subject do
    code, env = middleware.call(rack_env)
    [code, env['steam.liquid_assigns']['contact']]
  end

  context 'recaptcha has not been enabled' do

    it 'creates a new entry' do
      expect(subject.first).to eq 200
      expect(subject.last).to eq entry
    end

    context 'the form has not been set up for public submission' do

      let(:entry) { nil }

      it 'raises an exception with an explicit error message' do
        expect { subject }.to raise_exception('Unknown content type "contacts" or public_submission_enabled property not true')
      end

    end

  end

  context 'recaptcha has been enabled' do

    let(:recaptcha_enabled) { true }

    context 'the recaptcha response is valid' do

      let(:recaptcha_valid) { true }

      it 'creates a new entry' do
        expect(subject.first).to eq 200
        expect(subject.last).to eq entry
      end

    end

    context 'the recaptcha response is invalid' do

      let(:recaptcha_valid) { false }

      it 'returns a 200 code with the invalid entry' do
        expect(errors).to receive(:add).with(:recaptcha_invalid, true)
        expect(subject.first).to eq 200
        expect(subject.last).to eq entry
      end

    end

  end

  def build_env
    env_for('http://example.com/contact-us', params: form, method: method).tap do |env|
      env['steam.request']        = Rack::Request.new(env)
      env['steam.site']           = site
      env['steam.services']       = services
      env['rack.session']         = session
      env['steam.liquid_assigns'] = {}
    end
  end

end
