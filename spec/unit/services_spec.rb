require 'spec_helper'

describe Locomotive::Steam::Services do

  subject { Locomotive::Steam::Services.build_instance(nil) }

  describe 'configuration with a services hook' do

    before do
      Locomotive::Steam.configure do |config|
        config.services_hook = -> (services) {
          services.repositories = MyService.new
        }
      end
    end

    after { Locomotive::Steam.configure { |c| c.services_hook = nil } }

    it { expect(subject.repositories).to be_instance_of(MyService) }

    describe '#defer' do

      let(:status) { { initialized: false } }

      before do
        Locomotive::Steam.configure do |config|
          config.services_hook = -> (services) {
            services.defer(:repositories) { MyService.new(status) }
          }
        end
      end

      it { subject.repositories; expect(status[:initialized]).to eq false }
      it { subject.repositories.do; expect(status[:initialized]).to eq true }

    end

  end

  class MyService
    def initialize(status = {})
      status[:initialized] = true
    end
    def do; end
  end

end
