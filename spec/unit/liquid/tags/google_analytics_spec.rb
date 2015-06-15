require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::GoogleAnalytics do

  let(:source) { "{% google_analytics 42 %}" }

  subject { render_template(source) }

  it { is_expected.to include "_gaq.push(['_setAccount', '42']);" }

  describe 'raises an error if the syntax is incorrect' do
    let(:source) { '{% google_analytics %}' }
    it { expect { subject }.to raise_exception(::Liquid::SyntaxError) }
  end

end
