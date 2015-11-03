# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_fetcher/version'

Gem::Specification.new do |spec|
  spec.name          = "mail_fetcher"
  spec.version       = MailFetcher::VERSION
  spec.authors       = ["Vitalii Grygoruk"]
  spec.email         = ["vitaliy[dot]grigoruk[at]gmail[dot]com"]
  spec.summary       = %q{Simple utility that allows to fetch email messages from Gmail and MailCatcher}
  spec.description   = %q{Find email messages in Gmail and MailCatcher using the same Ruby API. Extremely useful for acceptance testing, that relies on emails sent by application under test.}
  spec.homepage      = "https://github.com/vgrigoruk/mail_fetcher"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  # spec.add_development_dependency "rake", "~> 10.0"
  # spec.add_development_dependency "rspec"
  spec.add_development_dependency "mailcatcher"

  spec.add_dependency "mail"
  spec.add_dependency "gmail_xoauth"
  spec.add_dependency "faraday", "~> 0.8.9"
  spec.add_dependency "faraday_middleware", "~> 0.9.0"
end
