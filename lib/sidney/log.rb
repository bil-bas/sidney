# encoding: utf-8

require 'logger'

module Sidney
  module Log
    LOG_FILE = File.open(File.join(LOG_PATH, "application.log"), "w")
    LOG_FILE.sync = true

    def self.included(base) # :nodoc:
      # Use class variables to store log objects for every class.
      base.class_eval do
        class << self
          attr_accessor :log # :nodoc:
        end
      end

      base.log = Logger.new(LOG_FILE)
      base.log.progname = base.name
      base.log.info { "Creating log" }
    end

    attr_reader :log
    def log # :nodoc:
      self.class.log
    end
  end
end