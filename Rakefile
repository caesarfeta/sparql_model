require 'rake/testtask'

Rake::TestTask.new do |t|
  t.libs << 'test'
end


FUSEKI_VERSION = "1.0.2"
FUSEKI_DIR = "jena-fuseki-#{FUSEKI_VERSION}"
FUSEKI_TAR = "#{FUSEKI_DIR}-distribution.tar.gz"

FUSEKI_EXE = "fuseki/#{FUSEKI_DIR}/fuseki-server"

desc "Run tests"
task :default => :test

desc 'Install sparql_model gem'
task :install do
  `gem build sparql_model.gemspec`
  `gem install sparql_model-0.0.1.gem`
end

namespace :server do
  desc 'Download and install Fuseki'
  task :install do
    `curl -O http://archive.apache.org/dist/jena/binaries/#{FUSEKI_TAR}`
    `mkdir fuseki`
    `tar xzvf #{FUSEKI_TAR} -C fuseki`
    `chmod +x #{FUSEKI_EXE} fuseki/#{FUSEKI_DIR}/s-**`
    `rm #{FUSEKI_TAR}`
  end

  desc 'Start the Fuseki test server at port 8080'
  task :start do
    Dir.chdir("fuseki/#{FUSEKI_DIR}") do
      IO.popen("./fuseki-server --update --mem --port=8080 /ds") do |f|
        f.each { |l| puts l }
      end
    end
  end
end

