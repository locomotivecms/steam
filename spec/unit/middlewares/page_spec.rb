# require 'spec_helper'

# require_relative '../../../lib/locomotive/steam/middlewares/base'
# require_relative '../../../lib/locomotive/steam/middlewares/page'

# describe Locomotive::Steam::Middlewares::Page do

#   before { skip }

#   let(:app) { ->(env) { [200, env, 'app'] }}

#   let :middleware do
#     Locomotive::Steam::Middlewares::Page.new(app)
#   end

#   context 'rack testing' do
#     let(:page) do
#       double(title: 'title', fullpath: 'fullpath')
#     end

#     before do
#       expect(middleware).to receive(:fetch_page).with('wk') { page }
#       expect(Locomotive::Common::Logger).to receive(:info).with("Found page \"title\" [fullpath]") { nil }
#     end

#     subject do
#       middleware.call env_for('http://www.example.com', { 'steam.locale' => 'wk' })
#     end

#     specify 'return 200' do
#       code, headers, response = subject
#       expect(code).to eq(200)
#     end

#     specify 'set page' do
#       code, headers, response = subject
#       expect(headers['steam.page']).to eq(page)
#     end
#   end

#   context 'test in isolation' do
#     describe '#path_combinations' do
#       specify do
#         expect(
#           middleware.send(:path_combinations, 'projects/project-2')
#         ).to eq(['projects/project-2', 'projects/*', '*/project-2'])
#       end
#     end
#   end

#   def env_for url, opts={}
#     Rack::MockRequest.env_for(url, opts)
#   end
# end
