module Locomotive::Steam
  module Middlewares
    module Concerns
      module AuthHelpers

        def authenticated?
          !!env['steam.authenticated_entry']
        end

        def authenticated_entry_type
          request.session[:authenticated_entry_type]
        end

        def store_authenticated(entry)
          type = entry ? entry.content_type.slug : authenticated_entry_type

          request.session[:authenticated_entry_type]  = type.to_s
          request.session[:authenticated_entry_id]    = entry&._id.to_s

          env['steam.authenticated_entry'] = nil if entry.nil?

          log "[Auth] authenticated #{type.to_s.singularize} ##{entry&._id.to_s}"

          liquid_assigns["current_#{type.singularize}"] = entry
        end

      end
    end
  end
end
