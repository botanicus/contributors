#!/usr/bin/env gem build
# encoding: utf-8

require "base64"

Gem::Specification.new do |s|
  s.name = "contributors"
  s.version = "0.1"
  s.authors = ["Jakub Stastny aka botanicus"]
  s.homepage = "http://github.com/botanicus/contributors"
  s.summary = "API for getting info about contributors of a project which is in Git."
  s.description = "The contributors gem is useful for getting informations about project contributors. It assumes that Git is used. In particular it can be used for generating CONTRIBUTORS file."
  s.cert_chain = nil
  s.email = Base64.decode64("c3Rhc3RueUAxMDFpZGVhcy5jeg==\n")
  s.has_rdoc = true

  # files
  s.files = `git ls-files`.split("\n")

  s.require_paths = ["lib"]

  # Ruby version
  # Current JRuby with --1.9 switch has RUBY_VERSION set to "1.9.2dev"
  # and RubyGems don't play well with it, so we have to set minimal
  # Ruby version to 1.9, even if it actually is 1.9.1
  s.required_ruby_version = ::Gem::Requirement.new("~> 1.9")

  begin
    require "changelog"
  rescue LoadError
    warn "You have to have changelog gem installed for post install message"
  else
    s.post_install_message = CHANGELOG.new.version_changes
  end

  # RubyForge
  s.rubyforge_project = "contributors"
end
