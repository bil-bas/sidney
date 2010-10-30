require 'rake/clean'
require 'fileutils'
include FileUtils

SOURCE_DIR = 'lib'
CLOBBER.include("doc/**/*", "sidney.exe")

APP = 'sidney'
APP_EXE = "#{APP}.exe"

# ------------------------------------------------------------------------------
desc "Compile #{APP_EXE}"
task :compile => APP_EXE

prerequisites = FileList["lib/#{APP}.rb*"]
file APP_EXE => prerequisites do
  puts "Creating exe using ocra"
  system "ocra #{prerequisites.join(' ')}"
  puts 'Done.'
end

desc "Delete ALL resources."
task :clobber_resources do
  rmtree "resources"
  rmtree "cache"
end

desc "Delete Yard docs."
task :clobber_yard do
  rmtree "doc"
end

desc "Generate Yard docs."
task :yard do
  system "yard doc lib"
end

desc "Import SiD resources."
task :import => :clobber_resources do
  system "rspec spec/resources/import_resources_spec.rb"
end

desc "Import SiD resources."
task :rspec do
  system "rspec spec"
end
