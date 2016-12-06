require 'spec_helper'

describe Locomotive::Steam::AuthService do

  let(:entries) { instance_double('ContentService') }
  let(:emails)  { instance_double('EmailService') }
  let(:service) { described_class.new(entries, emails) }

  let(:default_auth_options) { {
    type:               'accounts',
    id_field:           'email',
    id:                 'john@doe.net',
    password_field:     'password',
    password:           'easyone',
    reset_password_url: '/reset-password',
    reset_token:        '42',
    from:               'contact@acme.org',
    subject:            'Instructions for changing your password',
    email_handle:       'reset-password-email',
    smtp:               {}
  } }

  let(:auth_options) { instance_double('AuthOptions', default_auth_options) }

  describe '#sign_in' do

    subject { service.sign_in(auth_options) }

    it 'returns :wrong_credentials if no entry matches the email' do
      expect(entries).to receive(:all).with('accounts', { 'email' => 'john@doe.net' }).and_return([])
      is_expected.to eq :wrong_credentials
    end

    it "returns :wrong_credentials if the password doesn't the entry's password" do
      entry = build_account('fakeone')
      expect(entries).to receive(:all).with('accounts', { 'email' => 'john@doe.net' }).and_return([entry])
      is_expected.to eq :wrong_credentials
    end

    it "returns both :signed_in and the entry if the password matches the entry's password" do
      entry = build_account('easyone')
      expect(entries).to receive(:all).with('accounts', { 'email' => 'john@doe.net' }).and_return([entry])
      is_expected.to eq [:signed_in, entry]
    end

  end

  describe '#forgot_password' do

    let(:liquid_context) { {} }

    subject { service.forgot_password(auth_options, liquid_context) }

    it 'returns :wrong_email if no entry matches the email' do
      expect(entries).to receive(:all).with('accounts', { 'email' => 'john@doe.net' }).and_return([])
      is_expected.to eq :wrong_email
    end

    it 'sends the instructions by email if an entry matches the email' do
      allow(SecureRandom).to receive(:hex).and_return('42a')
      entry = build_account('easyone', '42a')
      expect(entries).to receive(:all).with('accounts', { 'email' => 'john@doe.net' }).and_return([entry])
      expect(entries).to receive(:update_decorated_entry)
      expect(emails).to receive(:send_email).with({
        from:         'contact@acme.org',
        to:           'john@doe.net',
        subject:      'Instructions for changing your password',
        page_handle:  'reset-password-email',
        smtp:         {} }, liquid_context)
      is_expected.to eq :reset_password_instructions_sent
      expect(liquid_context['reset_password_url']).to eq '/reset-password?auth_reset_token=42a'
    end

  end

  describe '#reset_password' do

    let(:_auth_options) { default_auth_options }
    let(:auth_options) { instance_double('AuthOptions', _auth_options) }

    subject { service.reset_password(auth_options) }

    context 'no auth token' do

      let(:_auth_options) { default_auth_options.merge({ reset_token: '' }) }
      it { is_expected.to eq :invalid_token }

    end

    context 'password too short' do

      let(:_auth_options) { default_auth_options.merge({ password: '' }) }
      it { is_expected.to eq :password_too_short }

    end

    context 'expired auth token' do

      it 'returns :invalid_token' do
        entry = instance_double('Account', :[] => (Time.zone.now - 3.hours).iso8601)
        expect(entries).to receive(:all).with('accounts', { '_auth_reset_token' => '42' }).and_return([entry])
        is_expected.to eq :invalid_token
      end

    end

    context 'valid auth token and password' do

      it 'returns :password_reset and entry' do
        entry = instance_double('Account', :[] => (Time.zone.now - 1.hours).iso8601)
        expect(entries).to receive(:all).with('accounts', { '_auth_reset_token' => '42' }).and_return([entry])
        expect(BCrypt::Password).to receive(:create).with('easyone').and_return('hashedeasyone')
        expect(entries).to receive(:update_decorated_entry).with(entry, { 'password_hash' => 'hashedeasyone', '_auth_reset_token' => nil, '_auth_reset_sent_at' => nil })
        is_expected.to eq [:password_reset, entry]
      end

    end

  end

  def build_account(password = 'easyone', reset_token = nil)
    encrypted_password = BCrypt::Password.create(password)
    entry = instance_double('Account', password: BCrypt::Password.new(encrypted_password))
    allow(entry).to receive(:[]).with(:password_hash).and_return(encrypted_password)
    allow(entry).to receive(:[]).with('_auth_reset_token').and_return(reset_token)
    entry
  end

end
