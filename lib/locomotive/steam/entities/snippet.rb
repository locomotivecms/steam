module Locomotive::Steam

  class Snippet

    include Locomotive::Steam::Models::Entity

    def initialize(attributes = {})
      super({
        template: {}
      }.merge(attributes))
    end

  end

end


# module Locomotive
#   module Steam

#     class SnippetRepository
#       module Filesystem
#         module Models

#           class Snippet < Base

#             set_localized_attributes [:template, :template_path]

#             def initialize(attributes)
#               super({ template: {} }.merge(attributes))
#             end

#           end

#         end
#       end
#     end

#   end
# end
