source 'https://rubygems.org'

gemspec

group :development do
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '4d1bd56'
  gem 'locomotivecms_common', path: '../common'
  # gem 'duktape', path: '../tmp/duktape.rb'
  # gem 'duktape', github: 'judofyr/duktape.rb', ref: '20ef6a5'
  # gem 'duktape', github: 'did/duktape.rb', branch: 'any-fixnum'

  gem 'puma',               '~> 6.1.0'
  gem 'haml',               '~> 6.1.1'

  gem 'rack', '~> 3.0.4.1'
  gem 'rack-mini-profiler', '~> 3.0.0'
  gem 'flamegraph'
  gem 'stackprof' # ruby 2.1+ only
  gem 'memory_profiler'
  gem 'rubocop'
end

group :test do
  gem 'rspec',              '~> 3.12.0'
  gem 'json_spec',          '~> 1.1.5'
  gem 'i18n-spec',          '~> 0.6.0'
  gem 'rack-test',          '~> 2.0.2'
  
  gem 'timecop',            '~> 0.9.6'
  gem 'pry-byebug', '~> 3.10.1'
  gem 'simplecov', require: false
  
end
