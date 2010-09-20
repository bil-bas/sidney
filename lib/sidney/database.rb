require 'active_record'
require 'log4r'

ActiveRecord::Base.logger = Logger.new(Sidney::Log::LOG_FILE)

file = File.join(ROOT_PATH, 'db', 'dbfile.sqlite3')
database_exists = File.exists? file

ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: file
    #database: ':memory:'
)

require 'schema' unless database_exists