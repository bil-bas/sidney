require "rspec"
require "fileutils"

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib", "sidney")
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib", "sidney", "resources")

ROOT_PATH = File.expand_path(File.join(File.dirname(__FILE__), ".."))
LOG_PATH = File.join(ROOT_PATH, "logs")

DATA_DIR = File.join(ROOT_PATH, "test_data")

INPUT_DIR =  File.join(DATA_DIR, "input")
GENERATED_DIR = File.join(DATA_DIR, "generated")

CACHE_IN = File.join(INPUT_DIR, "resourceCache")

ENV['PATH'] = "#{File.join(ROOT_PATH, 'bin')};#{ENV['PATH']}"

=begin
require 'ruby-prof'

RSpec.configure do |config|
  config.before(:all) do
    unless $ruby_prof_running
      $ruby_prof_running = true
      puts "--> Start profiler for #{described_class}"
      RubyProf.start
    end
  end

  config.after(:all) do
    if $ruby_prof_running
      result = RubyProf.stop

      puts "--> Stop profiler for #{described_class}"
      $ruby_prof_running = false
      dir = File.join(File.expand_path(File.dirname(__FILE__)), 'profiles')
      FileUtils.mkdir_p dir
      File.open(File.join(dir, "#{described_class.name[/[^:]+$/]}.txt"), 'w') do |file|
        printer = RubyProf::FlatPrinter.new(result)
        printer.print(file, min_percent: 0.1)
      end
    end
  end
end
=end