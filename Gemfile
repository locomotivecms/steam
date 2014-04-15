source 'https://rubygems.org'

gemspec

group :development do
  gem 'locomotivecms_common', '~> 0.0.1', require: 'common' # path: '../common'
  gem 'thin'
end

group :test do
  gem 'pry'
  gem 'coveralls', require: false
end

gem 'thin'

platform :jruby do
  ruby '1.9.3', engine: 'jruby', engine_version: '1.7.11'
end

platform :ruby do
  ruby '2.1.1'
end