require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/concerns/recaptcha'
require_relative '../../../lib/locomotive/steam/middlewares/entry_submission'

describe Locomotive::Steam::Middlewares::EntrySubmission do

  let(:app)                { ->(env) { [200, env, ['app']] } }
  let(:site)               { instance_double('Site', default_locale: 'en', locales: ['en']) }
  let(:middleware)         { described_class.new(app) }
  let(:service)            { instance_double('EntrySubmission') }
  let(:recaptcha)          { instance_double('Recaptcha') }
  let(:services)           { instance_double('Services', entry_submission: service, recaptcha: recaptcha, :locale= => 'en') }
  let(:session)            { {} }
  let(:method)             { 'POST' }
  let(:valid_recaptcha)    { true }
  let(:errors)             { instance_double('Error', empty?: false) }
  let(:entry)              { instance_double('Entry', errors: errors, content_type_slug: 'contacts') }
  let(:form)               { { content_type_slug: 'contacts', content: { email: 'john@doe.net' } } }

  before do
    allow_any_instance_of(described_class).to receive(:csrf_field).and_return('csrf_field')
    allow_any_instance_of(described_class).to receive(:recaptcha_content_entry_valid?).and_return(valid_recaptcha)
  end

  describe '#call' do

    let(:rack_env) { build_env }

    subject do
      code, env = middleware.call(rack_env)
      [code, env['steam.liquid_assigns']['contact']]
    end


    context 'with valid recaptcha' do

      before do
        expect(service).to receive(:submit).with('contacts', { email: 'john@doe.net' }).and_return(entry)
      end

      context 'the creation of a content entry returns nil' do

        let(:entry) { nil }

        it 'raises an exception' do
          expect { subject }.to raise_exception('Unknown content type "contacts" or public_submission_enabled property not true')
        end
      end
    end

    context 'with invalid recaptcha' do

      before do
        expect_any_instance_of(described_class).to receive(:build_invalid_recaptcha_entry).with('contacts', { email: 'john@doe.net' }).and_return(entry)
      end

      context 'the creation of a content entry is skip' do

        let(:valid_recaptcha)    { false }

        it 'should return a 200 with the invalid entry' do
          expect(subject).to eq [200, entry]
        end

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
