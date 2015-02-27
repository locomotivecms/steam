# module Locomotive
#   module Steam
#     module Repositories
#       module Filesystem
#         module YAMLLoaders

#           class ContentEntry < Struct.new(:root_path, :cache)

#             include YAMLLoaders::Concerns::Common

#             def list_of_attributes(content_type)
#               cache.fetch("data/#{content_type.slug}") { load_list(content_type) }
#             end

#             def write(content_type, attributes)
#               list = cache.read("data/#{content_type.slug}")

#               list << attributes.merge(content_type: content_type)
#             end

#             private

#             def load_list(content_type)
#               [].tap do |list|
#                 each(content_type.slug) do |label, attributes, position|
#                   default = { content_type: content_type, _position: position, _label: label.to_s }
#                   list << default.merge(attributes)
#                 end
#               end
#             end

#             def each(slug, &block)
#               position = 0
#               load(File.join(path, "#{slug}.yml")).each do |element|
#                 label, attributes = element.keys.first, element.values.first
#                 yield(label, attributes, position)
#                 position += 1
#               end
#             end

#             def path
#               File.join(root_path, 'data')
#             end

#           end

#         end
#       end
#     end
#   end
# end
