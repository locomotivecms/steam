module Locomotive::Steam
  module Middlewares

    # Process all the authentication actions:
    # - sign up
    # - sign in
    # - new reset password
    # - reset password
    # - sign out
    #
    # It is also in charge to load the current authenticated resource
    # from the session and put it in the liquid context.
    #
    class Auth < ThreadSafe

      include Helpers

      def _call
        load_authenticated_entry

        auth_options = AuthOptions.new(site, params)

        return unless auth_options.valid?

        send(:"#{auth_options.action}", auth_options)
      end

      private

      def sign_up(options)
        return if authenticated?

        status, entry = services.auth.sign_up(options, default_liquid_context, request)

        if status == :entry_created
          store_authenticated(entry)
          redirect_to options.callback || mounted_on
        else
          liquid_assigns['auth_entry'] = entry
        end

        append_message(status)
      end

      def sign_in(options)
        return if authenticated?

        status, entry = services.auth.sign_in(options, request)

        if status == :signed_in
          store_authenticated(entry)
          redirect_to options.callback || mounted_on
        end

        append_message(status)
      end

      def sign_out(options)
        return unless authenticated?

        services.auth.sign_out(load_authenticated_entry, request)

        store_authenticated(nil)

        append_message(:signed_out)
      end

      def forgot_password(options)
        return if authenticated?

        status = services.auth.forgot_password(options, default_liquid_context)

        append_message(status)
      end

      def reset_password(options)
        return if authenticated?

        status, entry = services.auth.reset_password(options)

        if status == :password_reset
          store_authenticated(entry)
          redirect_to options.callback || mounted_on
        end

        append_message(status)
      end

      def load_authenticated_entry
        entry_type = request.session[:authenticated_entry_type]
        entry_id   = request.session[:authenticated_entry_id]

        if entry = services.auth.find_authenticated_resource(entry_type, entry_id)
          env['authenticated_entry'] = entry
          liquid_assigns["current_#{entry_type.singularize}"] = entry
        end
      end

      def authenticated?
        !!env['authenticated_entry']
      end

      def store_authenticated(entry)
        type = entry ? entry.content_type.slug : request.session[:authenticated_entry_type]

        request.session[:authenticated_entry_type]  = type.to_s
        request.session[:authenticated_entry_id]    = entry.try(:_id).to_s

        log "[Auth] authenticated #{type.to_s.singularize} ##{entry.try(:_id).to_s}"

        liquid_assigns["current_#{type.singularize}"] = entry
      end

      def append_message(message)
        log "[Auth] status message = #{message.inspect}"

        message ||= 'error'
        liquid_assigns["auth_#{message}"] = "auth_#{message}"
      end

      class AuthOptions

        ACTIONS = %w(sign_up sign_in sign_out forgot_password reset_password)

        attr_reader :site, :params

        def initialize(site, params)
          @site, @params = site, params
        end

        def valid?
          ACTIONS.include?(action)
        end

        def action
          params[:auth_action]
        end

        def type
          params[:auth_content_type]
        end

        def id_field
          params[:auth_id_field] || :email
        end

        def password_field
          params[:auth_password_field].try(:to_sym) || :password
        end

        def id
          params[:auth_entry].try(:[], id_field) || params[:auth_id]
        end

        def password
          params[:auth_password]
        end

        def callback
          params[:auth_callback]
        end

        def reset_password_url
          params[:auth_reset_password_url]
        end

        def reset_token
          params[:auth_reset_token]
        end

        def from
          params[:auth_email_from] || 'support@locomotivecms.com'
        end

        def subject
          params[:auth_email_subject] || 'Instructions for changing your password'
        end

        def email_handle
          params[:auth_email_handle]
        end

        def disable_email
          [1, '1', 'true', true].include?(params[:auth_disable_email])
        end

        def entry
          params[:auth_entry]
        end

        def smtp
          name = params[:auth_email_smtp_namespace] || 'smtp'
          namespace = site.metafields.try(:[], name)

          if namespace.blank?
            Locomotive::Common::Logger.error "[Auth] Missing SMTP settings in the Site metafields. Namespace: #{name}".light_red
            return {}
          end

          {
            address:    namespace[params[:auth_email_smtp_address_alias] || 'address'],
            port:       namespace[params[:auth_email_smtp_port_alias] || 'port'],
            user_name:  namespace[params[:auth_email_smtp_user_name_alias] || 'user_name'],
            password:   namespace[params[:auth_email_smtp_password_alias] || 'password']
          }
        end

      end

    end

  end
end
