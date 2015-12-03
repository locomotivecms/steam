require_relative 'lib/locomotive/steam/version'

Gem::Specification.new do |spec|
  spec.name          = 'locomotivecms_steam'
  spec.version       = Locomotive::Steam::VERSION
  spec.authors       = ['Didier Lafforgue', 'Rodrigo Alvarez', 'Arnaud Sellenet', 'Joel Azemar']
  spec.email         = ['did@locomotivecms.com', 'papipo@gmail.com', 'arnaud@sellenet.fr', 'joel.azemar@gmail.com']
  spec.description   = %q{The LocomotiveCMS Steam is the rendering stack used by both Wagon and Engine}
  spec.summary       = %q{The LocomotiveCMS Steam is the rendering stack used by both Wagon and Engine}
  spec.homepage      = 'https://github.com/locomotivecms/steam'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler',    '~> 1.7'
  spec.add_development_dependency 'rake',       '~> 10.4.2'

  spec.add_dependency 'mongo',                  '~> 2.1.2'
  spec.add_dependency 'origin',                 '~> 2.1.1'

  spec.add_dependency 'nokogiri',               '~> 1.6.6.4'
  spec.add_dependency 'sanitize',               '~> 4.0.0'
  spec.add_dependency 'morphine',               '~> 0.1.1'
  spec.add_dependency 'httparty',               '~> 0.13.6'
  spec.add_dependency 'chronic',                '~> 0.10.2'

  spec.add_dependency 'rack-rewrite',           '~> 1.5.1'
  spec.add_dependency 'rack-cache',             '~> 1.2'
  spec.add_dependency 'dragonfly',              '~> 1.0.12'
  spec.add_dependency 'moneta',                 '~> 0.8.0'
  spec.add_dependency 'rack_csrf',              '~> 2.5.0'

  spec.add_dependency 'sprockets',              '~> 2.12.3'
  spec.add_dependency 'sprockets-sass',         '~> 1.3.1'
  spec.add_dependency 'sprockets-less',         '~> 0.6.1'
  spec.add_dependency 'coffee-script',          '~> 2.4.1'
  spec.add_dependency 'compass',                '~> 1.0.3'

  spec.add_dependency 'kramdown',               '~> 1.8.0'
  spec.add_dependency 'RedCloth',               '~> 4.2.9'
  spec.add_dependency 'github-markup',          '~> 1.4.0'
  spec.add_dependency 'haml',                   '~> 4.0.6'
  spec.add_dependency 'mimetype-fu',            '~> 0.1.2'
  spec.add_dependency 'mime-types',             '~> 2.6.1'

  spec.add_dependency 'locomotivecms-solid',      '~> 4.0.1'
  spec.add_dependency 'locomotivecms_common',     '~> 0.0.5'

  spec.required_ruby_version = '>= 2.0'
end
