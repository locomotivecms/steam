require 'maxmind/db'

module Locomotive::Steam
  module Middlewares

    # Set the locale from the path if possible or use the default one
    #
    # Examples:
    #
    #   /fr/index   => locale = :fr
    #   /fr/        => locale = :fr
    #   /index      => locale = :en (default one)
    #
    #   /en/index?locale=fr => locale = :fr
    #   /index      => redirection to /en if the locale in cookie is :en
    #
    class Locale < ThreadSafe

      include Helpers

      def _call
        env['steam.path']   = request.path_info

        env['steam.locale'] = services.locale = extract_locale

        country = extract_country
        env['steam.country'] = country

        set_locale_cookie
        set_country_cookie(country)

        log "Locale used: #{locale.upcase}"
        log "Country used: #{country.upcase}"

        I18n.with_locale(locale) do
          self.next
        end
      end

      protected

      def extract_country
        country =  country_from_params || country_from_cookie || country_from_geoip(env) || country_from_default
        country.to_s.downcase
      end

      def country_from_params
        params[:country]&.to_sym.tap do |country|
          log 'Country extracted from the params' unless country.blank?
        end
      end

      def country_from_cookie
        if country = services.cookie.get(cookie_country_key_name)
          log 'Country extracted from the cookie'
          country.to_sym
        end
      end

      def country_from_geoip(remote_ip)
        reader = MaxMind::DB.new('/home/akretion/GeoLite2-Country.mmdb', mode: MaxMind::DB::MODE_MEMORY)
        remote_ip = env["action_dispatch.remote_ip"].to_s
        record = reader.get(remote_ip)
        if record.nil?
          log "Country not found in database for: #{remote_ip}"
          return nil
        else
          log "Country found in database for: #{remote_ip}"
          return record['country']['iso_code']
        end
      end

      def country_from_default
        return "fr"
      end

      def locale_from_path
        path = request.path_info

        if path =~ /^\/(#{site.locales.join('|')})+(\/|$)/
          locale = $1

          # no need to keep the locale in the path used to fetch the page
          env['steam.path'] = path.gsub($1 + $2, '')
          env['steam.locale_in_path'] = true

          log 'Locale extracted from the path'

          locale.to_sym
        end
      end


      def extract_locale
        # Regarding the index page (basically, "/"), we've to see if we could
        # guess the locale from the headers the browser sends to us.
        locale = if is_index_page?
          locale_from_params || locale_from_cookie || locale_from_header
        else
          locale_from_path || locale_from_params
        end

        # make sure, the locale is among the ones defined in the site,
        # otherwise take the default one.
        locale && locales.include?(locale) ? locale : default_locale
      end

      def locale_from_params
        params[:locale]&.to_sym.tap do |locale|
          log 'Locale extracted from the params' unless locale.blank?
        end
      end

      def locale_from_path
        path = request.path_info

        if path =~ /^\/(#{site.locales.join('|')})+(\/|$)/
          locale = $1

          # no need to keep the locale in the path used to fetch the page
          env['steam.path'] = path.gsub($1 + $2, '')
          env['steam.locale_in_path'] = true

          log 'Locale extracted from the path'

          locale.to_sym
        end
      end

      def locale_from_header
        request.accept_language.lazy
        .sort { |a, b| b[1] <=> a[1] }
        .map  { |lang, _| lang[0..1].to_sym }
        .find { |lang| locales.include?(lang) }.tap do |locale|
          log 'Locale extracted from the header' unless locale.blank?
        end
      end

      def locale_from_cookie
        if locale = services.cookie.get(cookie_key_name)

          log 'Locale extracted from the cookie'

          locale.to_sym
        end
      end

      def set_locale_cookie
        services.cookie.set(cookie_key_name, {'value': locale, 'path': '/', 'max_age': 1.year})
      end


      def set_country_cookie(country)
        services.cookie.set(cookie_country_key_name, {'value': country, 'path': '/', 'max_age': 1.year})
      end

      # The preview urls for all the sites share the same domain, so cookie[:locale]
      # would be the same for all the preview urls and this is not good.
      # This is why we need to use a different key.
      def cookie_key_name
        live_editing? ? "steam-locale-#{site.handle}" : 'steam-locale'
      end

      def cookie_country_key_name
        live_editing? ? "steam-country-#{site.handle}" : 'steam-country'
      end

      def is_index_page?
        ['/', ''].include?(request.path_info)
      end

    end
  end
end
