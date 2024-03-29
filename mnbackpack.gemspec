# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mnbackpack/version"

Gem::Specification.new do |s|
  s.name        = "mnbackpack"
  s.version     = Mnbackpack::VERSION
  s.authors     = ["Chris Songer"]
  s.email       = ["csonger@gmail.com"]
  s.homepage    = ""
  s.summary     = "Gem to handle MediaNet content delivery and procurement"
  s.description = "Gem to handle MediaNet content delivery and procurement"

  s.rubyforge_project = "mnbackpack"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_dependency 'rails', '>=3.1.0'
  s.add_dependency 'rubyzip'
  s.add_dependency 'nokogiri'
  s.add_dependency 'typhoeus'
  s.add_dependency 'addressable'
  s.add_dependency 'ruby-hmac'
  s.add_dependency 'sunspot'
  s.add_dependency 'sunspot_solr'
  s.add_dependency 'sunspot_rails'
end
