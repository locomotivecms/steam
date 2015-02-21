raise 'NOT GOOD'

# module Locomotive
#   module Steam
#     module Repository

#       extend ActiveSupport::Concern

#       class RecordNotFound < StandardError; end

#       attr_accessor :adapter, :current_site, :current_locale

#       def initialize(adapter, current_site = nil, current_locale = nil)
#         @adapter        = adapter
#         @current_site   = current_site
#         @current_locale = current_locale
#       end

#       def all
#         adapter.all(mapper)
#       end

#       # def find(id)
#       #   adapter.find(mapper, id)
#       # end

#       def query(&block)
#         adapter.query(mapper, current_locale, &block)
#       end

#       # def create(entity)
#       #   entity.id = adapter.create(collection_name, entity)
#       # end

#       # def persisted?(entity)
#       #   !!entity.id && adapter.persisted?(collection_name, entity)
#       # end

#       # def update(entity)
#       #   adapter.update(collection_name, entity)
#       # end

#       # def destroy(entity)
#       #   adapter.destroy(collection_name, entity)
#       # end

#       def mapper
#         name, options, block = mapper_options
#         @mapper ||= Steam::Mapper.new(name, options, &block)
#       end

#       def scope
#         Steam::
#       end

#       # def collection_name
#       #   mapper.name
#       # end

#       module ClassMethods

#         def mapping(name, options = {}, &block)
#           class_eval do
#             define_method(:mapper_options) { [name, options, block] }
#           end
#         end

#       end

#     end
#   end
# end

# module Locomotive
#   module Steam
#     module Repositories
#     end
#   end
# end

# require_relative 'repositories/site_repository'
# require_relative 'repositories/page_repository'
