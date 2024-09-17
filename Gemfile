source 'https://rubygems.org'

gemspec

gem 'parser'

group :development do
  # gem 'locomotivecms_common', github: 'locomotivecms/common', ref: '4d1bd56'
  # gem 'locomotivecms_common', path: '../common'
  # gem 'duktape', path: '../tmp/duktape.rb'
  # gem 'duktape', github: 'judofyr/duktape.rb', ref: '20ef6a5'
  # gem 'duktape', github: 'did/duktape.rb', branch: 'any-fixnum'

  gem 'rake'

  gem 'puma',               '~> 6.4.0'
  gem 'haml',               '~> 6.2.3'

  gem 'rack', '~> 3.0'
  gem 'rack-mini-profiler', '~> 0.10.1'
  gem 'flamegraph'
  gem 'stackprof' # ruby 2.1+ only
  gem 'memory_profiler'
end

group :test do
  gem 'rspec',              '~> 3.12.0'
  gem 'json_spec',          '~> 1.1.5'
  gem 'i18n-spec',          '~> 0.6.0'

  gem 'timecop',            '~> 0.9.1'

  # gem 'pry-byebug',         '~> 3.3.0'

  gem 'rack-test',          '~> 2.1.0'

  gem 'simplecov',                  '~> 0.22.0', require: false
end
