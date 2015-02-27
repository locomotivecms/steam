# module Locomotive
#   module Steam
#     module Repositories
#       module Filesystem
#         module YAMLLoaders

#           class ContentType < Struct.new(:root_path, :cache)

#             include YAMLLoaders::Concerns::Common

#             def list_of_attributes
#               cache.fetch('app/content_types') { load_list }
#             end

#             private

#             def load_list
#               [].tap do |array|
#                 each_file do |filepath, slug|
#                   array << { slug: slug }.merge(load(filepath))
#                 end
#               end
#             end

#             def each_file(&block)
#               Dir.glob(File.join(path, "*.yml")).each do |filepath|
#                 slug = File.basename(filepath, '.yml')
#                 yield(filepath, slug)
#               end
#             end

#             def path
#               File.join(root_path, 'app', 'content_types')
#             end

#           end

#         end
#       end
#     end
#   end
# end
