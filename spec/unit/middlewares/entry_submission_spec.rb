require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/entry_submission'

describe Locomotive::Steam::Middlewares::EntrySubmission do

  let(:app)         { ->(env) { [200, env, ['app']] } }
  let(:site)        { instance_double('Site', default_locale: 'en', locales: ['en']) }
  let(:middleware)  { described_class.new(app) }
  let(:service)     { instance_double('EntrySubmission') }
  let(:services)    { instance_double('Services', entry_submission: service, :locale= => 'en') }
  let(:session)     { {} }
  let(:method)      { 'POST' }

  before do
    allow_any_instance_of(described_class).to receive(:csrf_field).and_return('csrf_field')
  end

  describe '#call' do

    let(:rack_env) { build_env }

    before do
      expect(service).to receive(:submit).with('contacts', { email: 'john@doe.net' }).and_return(entry)
    end

    subject { middleware.call(rack_env) }

    context 'the creation of a content entry returns nil' do

      let(:form)  { { content_type_slug: 'contacts', content: { email: 'john@doe.net' } } }
      let(:entry) { nil }

      it 'raises an exception' do
        expect { subject }.to raise_exception('Unknown content type "contacts" or public_submission_enabled property not true')
      end

    end

  end

  def build_env
    env_for('http://example.com/contact-us', params: form, method: method).tap do |env|
      env['steam.request']    = Rack::Request.new(env)
      env['steam.site']       = site
      env['steam.services']   = services
      env['rack.session']     = session
    end
  end

end
