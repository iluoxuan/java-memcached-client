# -*- mode: ruby -*-
# Generated by Buildr 1.2.10, change to your liking
# Version number for this release
VERSION_NUMBER = `git describe`.strip
# Version number for the next release
NEXT_VERSION = VERSION_NUMBER
# Group identifier for your projects
GROUP = "spy"
COPYRIGHT = "2006-2009  Dustin Sallings"

MAVEN_1_RELEASE = true
RELEASE_REPO = 'http://bleu.west.spy.net/~dustin/repo'
PROJECT_NAME = "memcached"

def compute_released_verions
  h = {}
  `git tag`.reject{|i| i =~ /pre|rc/}.map{|v| v.strip}.each do |v|
    a=v.split('.')
    h[a[0..1].join('.')] = v
  end
  require 'set'
  rv = Set.new h.values
  rv << VERSION_NUMBER
  rv
end

RELEASED_VERSIONS=compute_released_verions.sort.reverse

# Specify Maven 2.0 remote repositories here, like this:
repositories.remote << "http://www.ibiblio.org/maven2/"
repositories.remote << "http://bleu.west.spy.net/~dustin/m2repo/"

require 'buildr/java/emma'

plugins=[
  'spy:m1compat:rake:1.0',
  'spy:site:rake:1.2.4',
  'spy:git_tree_version:rake:1.0',
  'spy:build_info:rake:1.1.1'
]

plugins.each do |spec|
  artifact(spec).tap do |plugin|
    plugin.invoke
    load plugin.name
  end
end

desc "Java memcached client"
define "memcached" do

  test.options[:java_args] = "-ea"
  test.include "*Test"
  TREE_VER=tree_version
  puts "Tree version is #{TREE_VER}"

  project.version = VERSION_NUMBER
  project.group = GROUP
  manifest["Implementation-Vendor"] = COPYRIGHT
  compile.with "log4j:log4j:jar:1.2.15", "jmock:jmock:jar:1.2.0",
               "junit:junit:jar:4.4"

  # Gen build
  gen_build_info "net.spy.memcached", "git"
  compile.from "target/generated-src"
  resources.from "target/generated-rsrc"

  package(:jar).with :manifest =>
    manifest.merge("Main-Class" => "net.spy.memcached.BuildInfo")

  package :sources
  package :javadoc
  javadoc.using(:windowtitle => "javadocs for spymemcached #{TREE_VER}",
                :doctitle => "Javadocs for spymemcached #{TREE_VER}",
                :use => true,
                :charset => 'utf-8',
                :overview => 'src/main/java/net/spy/memcached/overview.html',
                :group => { 'Core' => 'net.spy.memcached' },
                :link => 'http://java.sun.com/j2se/1.5.0/docs/api/')

  emma.exclude 'net.spy.memcached.test.*'
  emma.exclude 'net.spy.memcached.BuildInfo'

end
# vim: syntax=ruby et ts=2
