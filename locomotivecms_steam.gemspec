require_relative 'lib/locomotive/steam/version'

Gem::Specification.new do |spec|
  spec.name          = 'locomotivecms_steam'
  spec.version       = Locomotive::Steam::VERSION
  spec.authors       = ['Didier Lafforgue', 'Rodrigo Alvarez', 'Arnaud Sellenet', 'Joel Azemar']
  spec.email         = ['didier@nocoffee.fr', 'papipo@gmail.com', 'arnaud@sellenet.fr', 'joel.azemar@gmail.com']
  spec.description   = %q{The LocomotiveCMS Steam is the rendering stack used by both Wagon and Engine}
  spec.summary       = %q{The LocomotiveCMS Steam is the rendering stack used by both Wagon and Engine}
  spec.homepage      = 'https://github.com/locomotivecms/steam'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rake',       '~> 12.3.0'

  spec.add_development_dependency 'mongo',      '~> 2.5.1'
  spec.add_development_dependency 'origin',     '~> 2.3.1'

  spec.add_dependency 'nokogiri',               '~> 1.8.2'
  spec.add_dependency 'sanitize',               '~> 4.6.4'
  spec.add_dependency 'morphine',               '~> 0.1.1'
  spec.add_dependency 'httparty',               '~> 0.16.0'
  spec.add_dependency 'chronic',                '~> 0.10.2'
  spec.add_dependency 'bcrypt',                 '~> 3.1.11'
  spec.add_dependency 'multi_json',             '~> 1.13.1'

  spec.add_dependency 'rack-rewrite',           '~> 1.5.1'
  spec.add_dependency 'rack-cache',             '~> 1.7.0'
  spec.add_dependency 'rack_csrf',              '~> 2.6.0'
  spec.add_dependency 'dragonfly',              '~> 1.2.0'
  spec.add_dependency 'moneta',                 '~> 1.0.0'

  spec.add_dependency 'sprockets',              '~> 3.7.1'
  spec.add_dependency 'sass',                   '~> 3.4.25'
  spec.add_dependency 'uglifier',               '~> 4.1.3'
  spec.add_dependency 'coffee-script',          '~> 2.4.1'
  spec.add_dependency 'compass',                '~> 1.0.3'
  spec.add_dependency 'autoprefixer-rails',     '~> 8.0.0'

  spec.add_dependency 'kramdown',               '~> 1.16.2'
  spec.add_dependency 'RedCloth',               '~> 4.3.2'
  spec.add_dependency 'mimetype-fu',            '~> 0.1.2'
  spec.add_dependency 'mime-types',             '~> 3.1.0'
  spec.add_dependency 'duktape',                '~> 2.0.1.1'
  spec.add_dependency 'pony',                   '~> 1.12'

  spec.add_dependency 'locomotivecms-solid',      '~> 4.0.1'
  spec.add_dependency 'locomotivecms_common',     '~> 0.3.1'

  spec.required_ruby_version = '>= 2.0'
end
