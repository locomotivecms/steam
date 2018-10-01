# Force ExecJS to select the best engine based on the current configuration.
# It means that if, down the road, we load a different javascript engine,
# the ExecJS runtime won't be affected.
require 'duktape'
require 'execjs'
ExecJS.runtimes.delete_if { |mod| mod.is_a?(ExecJS::DuktapeRuntime) }
ExecJS.instance_variable_set(:@runtime, ExecJS::Runtimes.autodetect)

module Locomotive
  module Steam

    class ActionService

      SERVICES = %w(content_entry api redirection)

      BUILT_IN_FUNCTIONS = %w(
        getProp
        setProp
        getSessionProp
        setSessionProp
        getCookiesProp
        setCookiesProp
        sendEmail
        allEntries
        findEntry
        createEntry
        updateEntry
        callAPI
        redirectTo)

      attr_accessor_initialize :site, :email, :services

      def run(script, params = {}, liquid_context)
        context = Duktape::Context.new

        define_built_in_functions(context, liquid_context)

        script = <<-JS
          function locomotiveAction(site, params) {
            #{script}
          }
        JS

        begin
          context.exec_string script
          context.call_prop('locomotiveAction', site.as_json, params)
        rescue Locomotive::Steam::RedirectionException
          raise
        rescue Exception => e
          raise Locomotive::Steam::ActionError.new(e, script)
        end
      end

      private

      SERVICES.each do |name|
        define_method(:"#{name}_service") { self.services[:"#{name}"] }
      end

      def define_built_in_functions(context, liquid_context)
        BUILT_IN_FUNCTIONS.each do |name|
          context.define_function name, &send(:"#{name.underscore}_lambda", liquid_context)
        end
      end

      def send_email_lambda(liquid_context)
        -> (options) { !!email.send_email(options, liquid_context) }
      end

      def get_prop_lambda(liquid_context)
        -> (name) { liquid_context[name].as_json }
      end

      def set_prop_lambda(liquid_context)
        -> (name, value) { liquid_context.scopes.last[name] = value }
      end

      def get_session_prop_lambda(liquid_context)
        -> (name) { liquid_context.registers[:session][name.to_sym].as_json }
      end

      def set_session_prop_lambda(liquid_context)
        -> (name, value) { liquid_context.registers[:session][name.to_sym] = value }
      end

      def get_cookies_prop_lambda(liquid_context)
        -> (name) { liquid_context.registers[:cookies][name.to_s].as_json }
      end

      def set_cookies_prop_lambda(liquid_context)
        -> (name, value) { liquid_context.registers[:cookies][name.to_s] = value.to_s }
      end

      def all_entries_lambda(liquid_context)
        -> (type, conditions) { content_entry_service.all(type, conditions, true) }
      end

      def find_entry_lambda(liquid_context)
        -> (type, id_or_slug) { content_entry_service.find(type, id_or_slug, true) }
      end

      def create_entry_lambda(liquid_context)
        -> (type, attributes) { content_entry_service.create(type, attributes, true) }
      end

      def update_entry_lambda(liquid_context)
        -> (type, id_or_slug, attributes) { content_entry_service.update(type, id_or_slug, attributes, true) }
      end

      def call_api_lambda(liquid_context)
        -> (method, url, options) { api_service.consume(url, (options || {}).with_indifferent_access.merge(method: method), true) }
      end

      def redirect_to_lambda(liquid_context)
        -> (page_handle, locale = nil) { redirection_service.redirect_to(page_handle, locale) }
      end

    end

  end
end
