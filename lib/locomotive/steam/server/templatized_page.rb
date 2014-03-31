module Locomotive::Steam
  class Server

    class TemplatizedPage < Middleware

      def call(env)
        self.set_accessors(env)

        if self.page && self.page.templatized?
          self.set_content_entry!(env)
        end

        app.call(env)
      end

      protected

      def set_content_entry!(env)
        %r(^#{self.page.safe_fullpath.gsub('*', '([^\/]+)')}$) =~ self.path

        permalink = $1

        if content_entry = self.page.content_type.find_entry(permalink)
          env['steam.content_entry'] = content_entry
        else
          env['steam.page'] = nil
        end
      end

    end
  end
end