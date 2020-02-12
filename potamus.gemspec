# frozen_string_literal: true

require File.expand_path('lib/potamus/version', __dir__)
Gem::Specification.new do |s|
  s.name          = 'potamus'
  s.description   = 'A utility tool for building Docker images'
  s.summary       = s.description
  s.homepage      = 'https://github.com/adamcooke/potamus'
  s.version       = Potamus::VERSION
  s.files         = Dir.glob('{bin,cli,lib}/**/*')
  s.require_paths = ['lib']
  s.authors       = ['Adam Cooke']
  s.email         = ['me@adamcooke.io']
  s.licenses      = ['MIT']
  s.cert_chain    = ['certs/adamcooke.pem']
  s.bindir = 'bin'
  s.executables << 'potamus'
  if $PROGRAM_NAME =~ /gem\z/
    s.signing_key = File.expand_path('~/.gem/signing-key.pem')
  end
  s.add_dependency 'swamp-cli', '>= 1.0', '< 2.0'
end
