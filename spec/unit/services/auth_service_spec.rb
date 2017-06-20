require 'spec_helper'

describe Locomotive::Steam::AuthService do

  let(:site)            { instance_double('CurrentSite') }
  let(:entries)         { instance_double('ContentService') }
  let(:emails)          { instance_double('EmailService') }
  let(:service)         { described_class.new(site, entries, emails) }
  let(:liquid_context)  { {} }

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

  describe '#sign_up' do

    let(:errors)                { [] }
    let(:entry_attributes)      { { fullname: 'Chris Cornell', band: 'Soundgarden', email: 'chris@soundgarden.band', password: 'easyone', password_confirmation:  'easyone' } }
    let(:entry)                 { instance_double('Account', errors: errors) }
    let(:email_disabled)        { false }
    let(:default_auth_options)  { {
      type:                   'accounts',
      id_field:               'email',
      id:                     'chris@soundgarden.band',
      password_field:         'password',
      from:                   'no-reply@acme.org',
      subject:                'Your account has been created',
      email_handle:           'account-created',
      smtp:                   {},
      disable_email:          email_disabled,
      entry:                  entry_attributes
    } }

    subject { service.sign_up(auth_options, liquid_context) }

    context 'the entry has errors' do

      let(:errors) { [:invalid_password] }

      it 'returns invalid_entry and the entry' do
        expect(entries).to receive(:create).with('accounts', {
          fullname:               'Chris Cornell',
          band:                   'Soundgarden',
          email:                  'chris@soundgarden.band',
          password:               'easyone',
          password_confirmation:  'easyone'
        }).and_return(entry)
        is_expected.to eq [:invalid_entry, entry]
      end

    end

    it "returns both :created and the entry if it was able to create it (+ send email)" do
      expect(entries).to receive(:create).with('accounts', {
        fullname:               'Chris Cornell',
        band:                   'Soundgarden',
        email:                  'chris@soundgarden.band',
        password:               'easyone',
        password_confirmation:  'easyone'
      }).and_return(entry)
      expect(emails).to receive(:send_email).with({
        from:         'no-reply@acme.org',
        to:           'chris@soundgarden.band',
        subject:      'Your account has been created',
        page_handle:  'account-created',
        smtp:         {} }, liquid_context)
      is_expected.to eq [:entry_created, entry]
    end

    context 'email is disabled' do

      let(:email_disabled) { true }

      it "doesn't send a notification email" do
        allow(entries).to receive(:create).and_return(entry)
        expect(emails).to_not receive(:send_email)
        is_expected.to eq [:entry_created, entry]
      end

    end

    describe Locomotive::Steam::AuthService::ContentEntryAuth do

      let(:repository)  { instance_double('FieldRepository', all: nil, required: []) }
      let(:type)        { instance_double('ContentType', slug: 'accounts', label_field_name: :title, fields: repository, fields_by_name: {}) }
      let(:attributes)  { { password: 'easyone', password_confirmation: 'easyone' } }
      let(:content_entry) { Locomotive::Steam::ContentEntry.new(attributes).tap { |e| e.content_type = type } }

      before { content_entry.extend(described_class) }

      describe '#valid?' do

        before { content_entry[:_password_field] = 'password' }

        subject { content_entry.valid? }

        it { is_expected.to eq true }

        it 'encrypts the password since there is no error' do
          expect(BCrypt::Password).to receive(:create).with('easyone').and_return('42a')
          subject
          expect(content_entry[:password_hash]).to eq '42a'
          expect(content_entry.attributes[:password]).to eq nil
          expect(content_entry.attributes[:password_confirmation]).to eq nil
        end

        context 'the password is less than 6 characters' do

          let(:attributes) { { password: 'easy', password_confirmation: 'easy' } }

          it 'returns false' do
            is_expected.to eq false
            expect(content_entry.errors[:password]).to eq(['is too short (minimum is 6 characters)'])
          end

        end

        context "the password doesn't match the confirmation" do

          let(:type)        { instance_double('ContentType', slug: 'accounts', label_field_name: :title, fields: repository, fields_by_name: {}, field_label_of: 'password') }
          let(:attributes)  { { password: 'easyone', password_confirmation: 'oneeasy' } }

          it 'returns false' do
            is_expected.to eq false
            expect(content_entry.errors[:password_confirmation]).to eq(["doesn't match password"])
          end

        end

      end

    end

  end

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

    subject { service.forgot_password(auth_options, liquid_context) }

    it 'returns :wrong_email if no entry matches the email' do
      expect(entries).to receive(:all).with('accounts', { 'email' => 'john@doe.net' }).and_return([])
      is_expected.to eq :wrong_email
    end

    it 'sends the instructions by email if an entry matches the email' do
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

    context 'no email template' do

      let(:_auth_options) { default_auth_options.merge(email_handle: nil) }
      let(:auth_options)  { instance_double('AuthOptions', _auth_options) }

      it 'also sends the instructions by email with a default email template' do
        entry = build_account('easyone', '42a')
        expect(entries).to receive(:all).with('accounts', { 'email' => 'john@doe.net' }).and_return([entry])
        expect(entries).to receive(:update_decorated_entry)
        expect(emails).to receive(:send_email).with({
          from:         'contact@acme.org',
          to:           'john@doe.net',
          subject:      'Instructions for changing your password',
          body:         (<<-EMAIL
Hi,
To reset your password please follow the link below: /reset-password?auth_reset_token=42a.
Thanks!
EMAIL
          ),
          smtp:         {} }, liquid_context)
        is_expected.to eq :reset_password_instructions_sent
        expect(liquid_context['reset_password_url']).to eq '/reset-password?auth_reset_token=42a'
      end

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
