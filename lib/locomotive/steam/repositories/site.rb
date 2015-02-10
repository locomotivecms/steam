module Locomotive
  module Steam
    module Repositories

      class Site

        def by_host(host, options = {})
          raise "TODO (#{options.inspect})"

          Locomotive::Site.where(:domains.in => host).first

          # Locomotive::Site.first
          # TODO multilocales
          # query(:en) do
          #   where('domains.in' => host)
          # end.first
        end

        def by_handle(handle)
          Locomotive::Site.where(handle: handle).first
        end

      end

    end
  end
end
