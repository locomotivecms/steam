# module Locomotive
#   module Steam
#     module Repositories
#       module Filesystem
#         module Sanitizers

#           class Snippet < Struct.new(:default_locale, :locales)

#             def apply_to(collection)
#               collection.each do |snippet|
#                 # if there a missing template in one of the locales,
#                 # then use the one from the default locale
#                 default = snippet.template_path[default_locale]

#                 locales.each do |locale|
#                   next if locale == default_locale
#                   snippet.template_path[locale] ||= default
#                 end
#               end
#             end

#           end

#         end
#       end
#     end
#   end
# end
