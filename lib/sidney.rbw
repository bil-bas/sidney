#!/usr/bin/env ruby

ROOT_PATH = if ENV['OCRA_EXECUTABLE']
  File.dirname(ENV['OCRA_EXECUTABLE'])
else
  File.dirname(File.dirname(__FILE__))
end

LOG_PATH = File.join(ROOT_PATH, 'logs')
STDERR_LOG_FILENAME = File.join(LOG_PATH, 'stderr.log')
STDOUT_LOG_FILENAME = File.join(LOG_PATH, 'stdout.log')

$LOAD_PATH.unshift(File.join(ROOT_PATH, 'lib', 'sidney'))



begin
  # Prevent warnings going to STDERR/STDOUT from killing the rubyw app.
  Dir.mkdir(LOG_PATH) unless File.exists? LOG_PATH
  
  original_stderr = $stderr.dup
  $stderr.reopen(STDERR_LOG_FILENAME)
  $stderr.sync = true

  original_stdout = $stdout.dup
  $stdout.reopen(STDOUT_LOG_FILENAME)
  $stdout.sync = true

  require 'game'
rescue Exception => ex
  $stderr.puts "FATAL ERROR - #{ex.class}: #{ex}\n#{ex.backtrace.join("\n")}"
  raise ex # Just to make sure that the user sees the error in the CLI/IDE too.
ensure
  $stderr.reopen(original_stderr) if defined? original_stderr
  $stdout.reopen(original_stdout) if defined? original_stdout
end