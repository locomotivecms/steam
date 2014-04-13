module Locomotive::Steam
  module Middlewares

    # Set the timezone according to the settings of the site
    #
    class Timezone < Base

      def _call(env)
        super

        Time.use_zone(site.try(:timezone) || 'UTC') do
          app.call(env)
        end
      end

    end
  end
end