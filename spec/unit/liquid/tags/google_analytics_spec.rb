require 'spec_helper'

describe Locomotive::Steam::Liquid::Tags::GoogleAnalytics do

  let(:context) { ::Liquid::Context.new({ 'ga_id' => '42' })}
  let(:source)  { "{% google_analytics 42 %}" }

  subject { render_template(source, context) }

  it { is_expected.to include %{<script async src="https://www.googletagmanager.com/gtag/js?id=42"></script>} }
  it { is_expected.to include "gtag('config', '42');" }

  describe 'passing a string' do

    let(:source) { "{% google_analytics 'ga-42' %}" }

    it { is_expected.to include %{<script async src="https://www.googletagmanager.com/gtag/js?id=ga-42"></script>} }
    it { is_expected.to include "gtag('config', 'ga-42');" }

  end

  describe 'passing a variable' do

    let(:source) { "{% google_analytics ga_id %}" }

    it { is_expected.to include %{<script async src="https://www.googletagmanager.com/gtag/js?id=42"></script>} }
    it { is_expected.to include "gtag('config', '42');" }

  end

  describe 'raises an error if the syntax is incorrect' do
    let(:source) { '{% google_analytics %}' }
    it { expect { subject }.to raise_exception(::Liquid::SyntaxError) }
  end

end
