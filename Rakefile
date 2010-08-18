require 'rake/rdoctask'
require 'rake/clean'
require 'fileutils'
include FileUtils

SOURCE_DIR = 'lib'
RDOC_DIR = File.join('doc', 'rdoc')

APP = 'sidney'
APP_EXE = "#{APP}.exe"

namespace :rdoc do
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = RDOC_DIR
    rdoc.rdoc_files.add(%w(*.rdoc doc/*.rdoc lib/**/*.rb))
    rdoc.title = 'Sidney - Story In A Box'
  end
end

namespace :compile do
  # ------------------------------------------------------------------------------
  desc "Compile #{APP_EXE}"

  task APP => APP_EXE

  prerequisites = FileList["lib/#{APP}.rb*"]
  file APP_EXE => prerequisites do
    puts "Creating exe using ocra"
    system "ocra #{prerequisites.join(' ')}"
    puts 'Done.'
  end
end