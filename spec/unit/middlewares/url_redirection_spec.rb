require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/url_redirection'

describe Locomotive::Steam::Middlewares::UrlRedirection do

  let(:redirections)    { [] }
  let(:site)            { instance_double('Site', _id: 42, url_redirections: redirections) }
  let(:url)             { 'http://models.example.com' }
  let(:locomotive_path) { nil }
  let(:app)             { ->(env) { [200, env, 'app'] } }
  let(:middleware)      { described_class.new(app) }

  subject do
    env = env_for(url, 'steam.site' => site)
    env['steam.request']    = Rack::Request.new(env)
    env['locomotive.path']  = locomotive_path
    code, env = middleware.call(env)
    [code, env['Location']]
  end

  describe 'no redirections' do

    it { is_expected.to eq [200, nil] }

  end

  describe 'redirections' do

    let(:redirections) { [['/foo.php', '/bar']] }

    it { is_expected.to eq [200, nil] }

    describe 'use first the locomotive.path env variable' do

      let(:locomotive_path) { '/foo.php' }
      it { is_expected.to eq [301, '/bar'] }

    end

    describe 'requesting the old url' do

      let(:url) { 'http://models.example.com/foo.php' }
      it { is_expected.to eq [301, '/bar'] }

      describe 'url with a lot of dots' do

        let(:redirections) { [['/content.HOME.HOME.WELCOME.DEU.GER.html', '/bar'], ['/hello', '/world']] }
        let(:url) { 'http://models.example.com/content.HOME.HOME.WELCOME.DEU.GER.html' }

        it { is_expected.to eq [301, '/bar'] }

      end

      describe 'url matching a pattern' do

        let(:redirections) { [['/old_images/:file', '/images/old/:file']] }
        let(:url) { 'http://models.example.com/old_images/cat.png' }

        it { is_expected.to eq [301, '/images/old/cat.png'] }

      end

      describe 'let the parent app know about the redirection when it happens' do

        let(:events) { [] }

        before {
          @subscriber = ActiveSupport::Notifications.subscribe('steam.serve.url_redirection') do |name, start, finish, id, payload|
            events << payload[:url]
          end
        }

        after { ActiveSupport::Notifications.unsubscribe(@subscriber) }

        it 'emits an event' do
          subject
          expect(events).to eq ['/foo.php']
        end

      end

      describe 'url with a query string' do

        let(:url) { 'http://models.example.com/foo.php?a=1' }

        it { is_expected.to eq [200, nil] }

        describe 'exact matching' do

          let(:redirections) { { '/foo.php?a=1' => '/bar' } }
          it { is_expected.to eq [301, '/bar'] }

        end

      end

    end

  end

end
