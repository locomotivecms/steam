module Locomotive::Steam
  module Middlewares

    # Process all the authentication actions:
    # - sign in
    # - new reset password
    # - reset password
    # - sign out
    #
    class Auth < ThreadSafe

      include Helpers

      ACTIONS = %w(sign_in sign_out send_password_reset reset_password)

      def _call
        load_authenticated_entry

        case params[:auth_action]
        when 'sign_in'  then sign_in
        when 'sign_out' then sign_out
        end

        # if ACTIONS.include?(params[:auth])
        #   sign_in if params[:auth] == 'sign_in'
        # end
      end

      private

      def load_authenticated_entry
        if (entry_id   = request.session[:authenticated_entry_id]) &&
           (entry_type = request.session[:authenticated_entry_type])

          env['authenticated_entry'] = find_entry(entry_type, entry_id)

          liquid_assigns["current_#{entry_type.singularize}"] = decorate_entry(env['authenticated_entry'])
        end
      end

      def find_entry(type, id)
        begin
          repositories.content_entry.with(type).find(id)
        rescue Exception => e
          log "Unable to find the authenticated entry: #{type}, #{id}"
          nil
        end
      end

      def authenticated?
        !!env['authenticated_entry']
      end

      def sign_out
        return unless authenticated?

        type = request.session[:authenticated_entry_type]

        request.session[:authenticated_entry_id] = nil
        request.session[:authenticated_entry_type] = nil

        liquid_assigns["current_#{type.singularize}"] = nil
        liquid_assigns['auth_signed_out'] = 'auth_signed_out'
      end

      def sign_in
        unless authenticated?
          if type = repositories.content_type.by_slug(params[:auth_content_type])
            id_field = params[:auth_id_field] || :email

            entry = repositories.content_entry.with(type).all(id_field => params[:auth_id]).first

            if entry && entry.password == params[:auth_password]
              request.session[:authenticated_entry_id] = entry._id
              request.session[:authenticated_entry_type] = type.slug

              liquid_assigns["current_#{type.slug.singularize}"] = decorate_entry(entry)

              redirect_to params[:auth_callback] || mounted_on
            else
              liquid_assigns['auth_wrong_credentials'] = 'auth_wrong_credentials'
            end
          else
            log "'#{params[:auth_content_type]}' is not a content type for authentication."
          end
        end
      end

    end

  end
end
