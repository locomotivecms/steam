# module Locomotive
#   module Steam
#     module Repositories
#       module Filesystem

#         class ContentType < Struct.new(:loader, :site, :current_locale)

#           include Concerns::Queryable

#           set_collection model: Filesystem::Models::ContentType, sanitizer: Filesystem::Sanitizers::ContentType

#           # Engine: site.where(slug: slug_or_content_type).first
#           def by_slug(slug_or_content_type)
#             if slug_or_content_type.is_a?(String)
#               query { where(slug: slug_or_content_type) }.first
#             else
#               slug_or_content_type
#             end
#           end

#           # Engine: content_type.entries_custom_fields.where(unique: true)
#           def look_for_unique_fields(content_type)
#             return nil if content_type.nil?

#             {}.tap do |hash|
#               content_type.query_fields { where(unique: true) }.each do |field|
#                 hash[field.name] = field
#               end
#             end
#           end

#           # Engine: content_type.entries_custom_fields
#           def fields_for(content_type)
#             return nil if content_type.nil?

#             content_type.fields
#           end

#           # Engine: content_type.entries.klass.send(:"#{name}_options").map { |option| option['name'] }
#           def select_options(content_type, name)
#             return nil if content_type.nil? || name.nil?

#             field = content_type.fields_by_name[name]

#             if field.type == :select
#               localized_attribute(field, :select_options)
#             else
#               nil
#             end
#           end

#         end

#       end
#     end
#   end
# end
