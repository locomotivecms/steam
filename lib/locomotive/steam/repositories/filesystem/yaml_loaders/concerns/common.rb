# module Locomotive
#   module Steam
#     module Repositories
#       module Filesystem
#         module YAMLLoaders
#           module Concerns

#             module Common

#               def load(path, frontmatter = false, &block)
#                 if File.exists?(path)
#                   yaml      = File.open(path).read.force_encoding('utf-8')
#                   template  = nil

#                   if frontmatter && match = yaml.match(FRONTMATTER_REGEXP)
#                     yaml, template = match[:yaml], match[:template]
#                   end

#                   HashConverter.to_sym(YAML.load(yaml)).tap do |attributes|
#                     block.call(attributes, template) if block_given?
#                   end
#                 else
#                   Locomotive::Common::Logger.error "No #{path} file found"
#                   {}
#                 end
#               end

#               def template_extensions
#                 @extensions ||= %w(liquid haml)
#               end

#             end

#           end
#         end
#       end
#     end
#   end
# end
