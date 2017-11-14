module Locomotive
  module Steam

    class AuthService

      MIN_PASSWORD_LENGTH   = 6
      RESET_TOKEN_LIFETIME  = 1 * 3600 # 6 hours in seconds
      ACTIONS = %w(sign_up sign_in sign_out forgot_password reset_password)

      attr_accessor_initialize :site, :entries, :email_service

      def valid_action?(options)
        ACTIONS.include?(options.action)
      end

      def find_authenticated_resource(type, id)
        entries.find(type, id)
      end

      def sign_up(options, context, request = nil)
        entry = entries.create(options.type, options.entry) do |_entry|
          _entry.extend(ContentEntryAuth)
          _entry[:_password_field] = options.password_field.to_sym
        end

        if entry.errors.empty?
          notify(:signed_up, entry, request)
          context[options.type.singularize] = entry
          send_welcome_email(options, context)
        end

        [entry.errors.empty? ? :entry_created : :invalid_entry, entry]
      end

      def sign_in(options, request)
        entry = entries.all(options.type, options.id_field => options.id).first

        if entry
          hashed_password = entry[:"#{options.password_field}_hash"]
          password        = ::BCrypt::Engine.hash_secret(options.password, entry.send(options.password_field).try(:salt))
          same_password   = secure_compare(password, hashed_password)

          if same_password
            notify(:signed_in, entry, request)
            return [:signed_in, entry]
          end
        end

        :wrong_credentials
      end

      def sign_out(entry, request)
        notify(:signed_out, entry, request)

        :signed_out
      end

      # options is an instance of the AuthOptions class
      def forgot_password(options, context)
        entry = entries.all(options.type, options.id_field => options.id).first

        if entry.nil?
          :"wrong_#{options.id_field}"
        else
          entries.update_decorated_entry(entry, {
            '_auth_reset_token'   => SecureRandom.hex,
            '_auth_reset_sent_at' => Time.zone.now.iso8601
          })

          context['reset_password_url'] = options.reset_password_url + '?auth_reset_token=' + entry['_auth_reset_token']
          context[options.type.singularize] = entry

          send_reset_password_instructions(options, context)

          :"reset_#{options.password_field}_instructions_sent"
        end
      end

      def reset_password(options)
        return :invalid_token       if options.reset_token.blank?
        return :password_too_short  if options.password.to_s.size < MIN_PASSWORD_LENGTH

        entry = entries.all(options.type, '_auth_reset_token' => options.reset_token).first

        if entry
          sent_at = Time.parse(entry[:_auth_reset_sent_at]).to_i
          now = Time.zone.now.to_i - RESET_TOKEN_LIFETIME

          if sent_at >= now
            entries.update_decorated_entry(entry, {
              "#{options.password_field}_hash" => BCrypt::Password.create(options.password),
              '_auth_reset_token'   => nil,
              '_auth_reset_sent_at' => nil
            })

            return [:"#{options.password_field}_reset", entry]
          end
        end

        :invalid_token
      end

      private

      def send_welcome_email(options, context)
        return if options.disable_email

        send_email options, context, <<-EMAIL
Hi,
You've been successfully registered.
Thanks!
EMAIL
      end

      def send_reset_password_instructions(options, context)
        send_email options, context, <<-EMAIL
Hi,
To reset your password please follow the link below: #{context['reset_password_url']}.
Thanks!
EMAIL
      end

      def send_email(options, context, default_body)
        email_options = { from: options.from, to: options.id, subject: options.subject, smtp: options.smtp }

        if options.email_handle
          email_options[:page_handle] = options.email_handle
        else
          email_options[:body] = default_body
        end

        email_service.send_email(email_options, context)
      end

      # https://github.com/plataformatec/devise/blob/88724e10adaf9ffd1d8dbfbaadda2b9d40de756a/lib/devise.rb#L485
      def secure_compare(a, b)
        return false if a.blank? || b.blank? || a.bytesize != b.bytesize
        l = a.unpack "C#{a.bytesize}"

        res = 0
        b.each_byte { |byte| res |= byte ^ l.shift }
        res == 0
      end

      def notify(action, entry, request)
        ActiveSupport::Notifications.instrument("steam.auth.#{action}",
          site:     site,
          entry:    entry,
          locale:   entries.locale,
          request:  request
        )
      end

      # Module inject to the content entry to enable
      # related authentication methods.
      #
      module ContentEntryAuth

        def valid?
          super

          name          = self[:_password_field]
          password      = self[name]
          confirmation  = self["#{name}_confirmation"]

          if password.to_s.size < Locomotive::Steam::AuthService::MIN_PASSWORD_LENGTH
            self.errors.add(name, :too_short, count: Locomotive::Steam::AuthService::MIN_PASSWORD_LENGTH)
          end

          if !password.blank? && password != confirmation
            self.errors.add("#{name}_confirmation", :confirmation, attribute: self._label_of(name))
          end

          set_password(password) if self.errors.empty?

          self.errors.empty?
        end

        private

        def set_password(password)
          self[:"#{self[:_password_field]}_hash"] = BCrypt::Password.create(password)

          name = self.attributes.delete(:_password_field)

          self.attributes.delete_if { |_name| _name == name || _name == "#{name}_confirmation" }
        end

      end

    end

  end
end
