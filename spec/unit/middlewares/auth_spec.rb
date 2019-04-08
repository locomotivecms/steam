require 'spec_helper'

require_relative '../../../lib/locomotive/steam/middlewares/thread_safe'
require_relative '../../../lib/locomotive/steam/middlewares/helpers'
require_relative '../../../lib/locomotive/steam/middlewares/auth'

describe Locomotive::Steam::Middlewares::Auth::AuthOptions do

  let(:metafields)  { { 'smtp' => { 'address' => '127.0.0.1', 'user_name' => 'John', 'password' => 'doe', 'port' => 25 } } }
  let(:site)        { instance_double('Site', metafields: metafields) }
  let(:params)      { {} }

  let(:options) { described_class.new(site, params) }

  describe '#smtp' do

    subject { options.smtp }

    it { is_expected.to eq(
        address: '127.0.0.1',
        user_name: 'John',
        password: 'doe',
        port: 25,
        authentication: 'plain',
        enable_starttls_auto: false,
    ) }

    context 'no smtp metafields' do

      let(:metafields) { {} }

      it { is_expected.to eq({}) }

    end

  end

end
