require 'spec_helper'

describe Locomotive::Steam::Liquid::Drops::SessionProxy do

  let(:request)   { instance_double('Request', session: { answer: 42 }) }
  let(:context)   { ::Liquid::Context.new({}, {}, { request: request }) }
  let(:drop)      { Locomotive::Steam::Liquid::Drops::SessionProxy.new.tap { |d| d.context = context } }

  subject { drop['answer'] }

  it { is_expected.to eq 42 }

end
