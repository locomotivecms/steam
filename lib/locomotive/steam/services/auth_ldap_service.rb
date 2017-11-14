require 'net-ldap'

module Locomotive
  module Steam

    class AuthLdapService

      attr_accessor_initialize :site, :entries

      ACTIONS = %w(sign_in sign_out)

      def valid_action?(options)
        ACTIONS.include?(options.action)
      end

      def find_authenticated_resource(type, id)
        entries.find(type, id)
      end

      def sign_in(options, request)
        entry = entries.all(options.type, options.id_field => options.id).first
        # in ldap case options.id_field must be the email
        if entry
          if sign_in_ldap(options.id, options.password)
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

      private

      def sign_in_ldap(email, password)
        config = site.metafields['auth_provider']
        ldap = Net::LDAP.new
        ldap.host = config['ldap_host']
        ldap.port = config['ldap_port']
        ldap.auth config['ldap_dn'], config['ldap_password']
        result = ldap.bind_as(
          :base => config['ldap_base'],
          :filter => "(mail=#{email})",
          :password => password
        )
      end

      def notify(action, entry, request)
        ActiveSupport::Notifications.instrument("steam.auth.#{action}",
          site:     site,
          entry:    entry,
          locale:   entries.locale,
          request:  request
        )
      end

    end

  end
end
