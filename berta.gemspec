Gem::Specification.new do |s|
  s.name = 'berta'
  s.version = '0.0.0'
  s.summary = 'Berta VM expiration tool'
  s.description = 'Berta will check all VMs on OpenNebula cloud for expiration date'
  s.authors = ['Dusan Baran']
  s.email = 'dbaran@hotmail.sk'
  s.license = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_development_dependency 'bundler', '~> 1.13'
  s.add_development_dependency 'rake', '~> 11.2'
  s.add_development_dependency 'rspec', '~> 3.5'
  s.add_development_dependency 'rubocop', '~> 0.42'
  s.add_development_dependency 'pry', '~> 0.10'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'vcr'

  s.add_runtime_dependency 'thor', '~> 0.19'
  s.add_runtime_dependency 'settingslogic', '~> 2.0'
  s.add_runtime_dependency 'yell', '~> 2.0'
  s.add_runtime_dependency 'opennebula', '5.2.0'
end
