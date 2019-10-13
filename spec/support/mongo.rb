require 'mongo'

# Mongo::Logger.logger.level = Logger::INFO
Mongo::Logger.logger       = Logger.new($stdout)
Mongo::Logger.logger.level = Logger::DEBUG
