module Locomotive
  module Steam

    class AuthService

      attr_accessor_initialize :entries, :email_service

      def find_authenticated_resource(type, id)
        entries.find(type, id)
      end

      def sign_in(options)
        entry = entries.all(options.type, options.id_field => options.id).first

        if entry
          hashed_password = entry[:"#{options.password_field}_hash"]
          password        = ::BCrypt::Engine.hash_secret(options.password, entry.send(options.password_field).try(:salt))
          same_password   = secure_compare(password, hashed_password)

          return [:signed_in, entry] if same_password
        end

        :wrong_credentials
      end

      # options is an instance of the AuthOptions class
      def forgot_password(options, context)
        entry = entries.all(options.type, options.id_field => options.id).first

        if entry.nil?
          :wrong_email
        else
          entries.update_decorated_entry(entry, {
            '_auth_reset_token'   => SecureRandom.hex,
            '_auth_reset_sent_at' => Time.zone.now
          })

          context['reset_password_url'] = options.reset_password_url + '?token=' + entry['_auth_reset_token']
          context[options.type.singularize] = entry

          send_reset_password_instructions(options, context)

          :reset_password_instructions_sent
        end
      end

      private

      def send_reset_password_instructions(options, context)
        email_options = { from: options.from, to: options.id, subject: options.subject, smtp: options.smtp }

        if options.email_handle
          email_options[:page_handle] = options.email_handle
        else
          email_options[:body] = <<-EMAIL
Hi,
To reset your password please follow the link below: #{context['reset_password_url']}.
Thanks!
EMAIL
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

    end

  end
end
