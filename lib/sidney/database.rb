require 'active_record'
require 'activerecord-import'
require 'logger'
require 'sqlite3'

require_relative 'log'

ActiveRecord::Base.logger = Logger.new(File.join(LOG_PATH, "application.log"))
ActiveRecord::LogSubscriber.colorize_logging = false
ActiveRecord::Base.logger.level = Logger::INFO # Or ::DEBUG

file = File.join(ROOT_PATH, 'resources', 'database.sqlite3')
database_exists = File.exists? file

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: file
)

require 'schema' unless database_exists