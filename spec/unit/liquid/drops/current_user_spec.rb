require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::CurrentUser do

  let(:drop) { Locomotive::Steam::Liquid::Drops::CurrentUser.new(user) }

  subject { drop }

  context 'not logged in' do

    let(:user) { nil }

    describe '#logged_in?' do
      it { expect(subject.logged_in?).to eq false }
    end

    describe '#name' do
      it { expect(subject.name).to eq nil }
    end

    describe '#email' do
      it { expect(subject.email).to eq nil }
    end

  end

  context 'logged in' do

    let(:user) { instance_double('User', name: 'John', email: 'john@doe.net') }

    describe '#logged_in?' do
      it { expect(subject.logged_in?).to eq true }
    end

    describe '#name' do
      it { expect(subject.name).to eq 'John' }
    end

    describe '#email' do
      it { expect(subject.email).to eq 'john@doe.net' }
    end

  end

end
