$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'middleman/apps/version'

Gem::Specification.new do |s|
  s.name        = 'middleman-apps'
  s.version     = Middleman::Apps::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Nikhil Gupta']
  s.email       = ['me@nikhgupta.com']
  s.homepage    = 'https://github.com/nikhgupta/middleman-apps'
  s.summary     = 'Middleman extension to run dynamic pages using Sinatra'
  s.description = 'Middleman extension to run dynamic pages using Sinatra'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']
  s.executables   = `git ls-files -- bin/*`.split("\n").map do |f|
    File.basename(f)
  end

  s.add_runtime_dependency('middleman-core', ['~> 4.2'])
  s.add_runtime_dependency('sinatra', ['~> 2.0'])
  s.add_runtime_dependency('activesupport', ['>= 4.2'])
  s.add_runtime_dependency('sinatra-contrib', ['~> 2.0'])
  # s.add_runtime_dependency('rack-contrib', ['>= 1.7.0'])

  s.add_development_dependency('middleman-cli')
end
