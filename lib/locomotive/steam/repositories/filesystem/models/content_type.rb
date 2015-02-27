# module Locomotive
#   module Steam
#     module Repositories
#       module Filesystem
#         module Models

#           class ContentType < Base

#             attr_accessor :fields, :fields_by_name

#             def initialize(attributes = {})
#               super({
#                 order_by:         '_position',
#                 order_direction:  'asc'
#               }.merge(attributes))
#             end

#             def label_field_name
#               (self[:label_field_name] || fields.first.name).to_sym
#             end

#             def localized_fields_names
#               query_fields { where(localized: true) }.all.map(&:name)
#             end

#             def order_by
#               name = self[:order_by] == 'manually' ? '_position' : self[:order_by]
#               "#{name} #{self.order_direction}"
#             end

#             def query_fields(&block)
#               Filesystem::MemoryAdapter::Query.new(fields, &block)
#             end

#           end

#         end
#       end
#     end
#   end
# end
