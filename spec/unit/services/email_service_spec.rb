require 'spec_helper'

describe Locomotive::Steam::EmailService do

  let(:page)          { nil }
  let(:page_finder)   { instance_double('PageFinder', by_handle: page) }
  let(:liquid_parser) { Locomotive::Steam::LiquidParserService.new(nil, nil) }
  let(:asset_host)    { instance_double('AssetHost') }
  let(:simulation)    { false }
  let(:service)       { described_class.new(page_finder, liquid_parser, asset_host, simulation) }

  # uncomment the line below for DEBUG purpose
  before { allow(service.logger).to receive(:info).and_return(true) }

  describe '#send' do

    let(:smtp_options)  { { address: 'smtp.example.com', user_name: 'user', password: 'password' } }
    let(:options)       { { to: 'john@doe.net', from: 'me@locomotivecms.com', subject: 'Hello world', body: 'Hello {{ to }}', smtp: smtp_options, html: false } }
    let(:context)       { ::Liquid::Context.new({ 'name' => 'John', 'to' => 'john@doe.net' }, {}, {}) }

    subject { service.send_email(options, context) }

    it 'sends the email over Pony' do
      expect(Pony).to receive(:mail).with({
        to:           'john@doe.net',
        from:         'me@locomotivecms.com',
        subject:      'Hello world',
        body:         'Hello john@doe.net',
        via:          :smtp,
        via_options:  {
          address:    'smtp.example.com',
          user_name:  'user',
          password:   'password'
        }
      })
      subject
    end

    context 'simulation mode' do

      let(:simulation) { true }

      it "doesn't call Pony.mail" do
        expect(Pony).not_to receive(:mail)
        subject
      end

    end

    describe 'no body, no page handle' do

      let(:options) { { to: 'john@doe.net', from: 'me@locomotivecms.com', subject: 'Hello world', smtp: smtp_options, html: false } }

      it { expect { subject }.to raise_error('[EmailService] the body or page_handle options are missing.')}

    end

    describe 'use a page as the body of the email' do

      let(:page)    { instance_double('Page', liquid_source: '<html><body><h1>Hello {{ name }}</h1></body></html>') }
      let(:options) { { to: 'john@doe.net', from: 'me@locomotivecms.com', subject: 'Hello world', page_handle: 'notification-email', smtp: smtp_options, html: true } }

      it 'sends the email over Pony' do
        expect(Pony).to receive(:mail).with({
          to:           'john@doe.net',
          from:         'me@locomotivecms.com',
          subject:      'Hello world',
          html_body:    '<html><body><h1>Hello John</h1></body></html>',
          via:          :smtp,
          via_options:  {
            address:    'smtp.example.com',
            user_name:  'user',
            password:   'password'
          }
        })
        subject
      end

      context "the page doesn't exist" do

        let(:page) { nil }

        it { expect { subject }.to raise_error('[EmailService] No page found with the following handle: notification-email') }

      end

    end

    describe 'with attachments' do

      let(:options) { { to: 'john@doe.net', from: 'me@locomotivecms.com', subject: 'Hello world', body: 'Hello {{ to }}', smtp: smtp_options, attachments: attachments, html: false } }

      context 'local attachment' do

        let(:attachments) { { 'foo.txt' => '/local/foo.txt' } }

        before do
          expect(asset_host).to receive(:compute).with('/local/foo.txt', false).and_return('http://acme.org/local/foo.txt')
          expect(Net::HTTP).to receive(:get).with(URI('http://acme.org/local/foo.txt')).and_return('Foo')
        end

        it 'sends the email over Pony' do
          expect(Pony).to receive(:mail).with({
            to:           'john@doe.net',
            from:         'me@locomotivecms.com',
            subject:      'Hello world',
            body:         'Hello john@doe.net',
            attachments:  { 'foo.txt' => 'Foo' },
            via:          :smtp,
            via_options:  {
              address:    'smtp.example.com',
              user_name:  'user',
              password:   'password'
            }
          })
          subject
        end

      end

      context 'remote attachment' do

        let(:attachments) { { 'bar.txt' => 'http://acme.org/bar.txt' } }

        it 'sends the email over Pony' do
          expect(Net::HTTP).to receive(:get).with(URI('http://acme.org/bar.txt')).and_return('Bar')
          expect(Pony).to receive(:mail).with({
            to:           'john@doe.net',
            from:         'me@locomotivecms.com',
            subject:      'Hello world',
            body:         'Hello john@doe.net',
            attachments:  { 'bar.txt' => 'Bar' },
            via:          :smtp,
            via_options:  {
              address:    'smtp.example.com',
              user_name:  'user',
              password:   'password'
            }
          })
          subject
        end

        context 'attachment not found' do

          it "doesn't send the email" do
            expect(Net::HTTP).to receive(:get).with(URI('http://acme.org/bar.txt')).and_raise('URL not responding')
            expect(Pony).to receive(:mail).with({
              to:           'john@doe.net',
              from:         'me@locomotivecms.com',
              subject:      'Hello world',
              body:         'Hello john@doe.net',
              attachments:  { 'bar.txt' => nil },
              via:          :smtp,
              via_options:  {
                address:    'smtp.example.com',
                user_name:  'user',
                password:   'password'
              }
            })
            subject
          end

        end

      end

      context 'inline string' do

        let(:attachments) { { 'bar.txt' => 'Bar' } }

        it 'sends the email over Pony' do
          expect(Pony).to receive(:mail).with({
            to:           'john@doe.net',
            from:         'me@locomotivecms.com',
            subject:      'Hello world',
            body:         'Hello john@doe.net',
            attachments:  { 'bar.txt' => 'Bar' },
            via:          :smtp,
            via_options:  {
              address:    'smtp.example.com',
              user_name:  'user',
              password:   'password'
            }
          })
          subject
        end

      end

    end

  end
end
