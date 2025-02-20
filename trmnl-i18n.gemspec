# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "trmnl-i18n"
  spec.version = "0.0.0"
  spec.authors = ["Brooke Kuhlmann"]
  spec.email = ["brooke@alchemists.io"]
  spec.homepage = "https://github.com/usetrmnl/trmnl-i18n"
  spec.summary = "A collection of TRMNL locales."
  spec.license = "MIT"

  spec.metadata = {
    "bug_tracker_uri" => "https://github.com/usetrmnl/trmnl-i18n/issues",
    "changelog_uri" => "https://github.com/usetrmnl/trmnl-i18n/tags",
    "homepage_uri" => "https://github.com/usetrmnl/trmnl-i18n",
    "label" => "TRMNL I18n",
    "rubygems_mfa_required" => "true",
    "source_code_uri" => "https://github.com/usetrmnl/trmnl-i18n"
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.required_ruby_version = "~> 3.4"
  spec.add_dependency "railties", "~> 8.0"

  spec.extra_rdoc_files = Dir["README*", "LICENSE*"]
  spec.files = Dir["*.gemspec", "lib/**/*"]
end
