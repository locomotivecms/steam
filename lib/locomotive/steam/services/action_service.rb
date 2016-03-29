# TODO: accessor to other services: email, content_entry CRUD actions

# built-in functions (prefix by a namespace? or included in a module):
# x site
# x sendEmail(params) => nil
# x setProp(key, value) # Liquid context (assigns)
# x getProp(key) # Liquid context (assigns)
# x setSessionProp(key, value)
# x getSessionProp(key)
# x allEntries(type, filters) => Array of hashes
# x findEntry(type, <id_or_slug>)
# - createEntry(<type>, attributes) => Hash (with id)
# - updateEntry(<type>, <id_or_slug>, attributes)

# liquid tag: {% action '<name>' %}<coffee script here>{% endaction %}

require 'duktape'

module Locomotive
  module Steam

    class ActionService

      BUILT_IN_FUNCTIONS = %w(
        getProp
        sendProp
        getSessionProp
        setSessionProp
        sendEmail
        allEntries
        findEntry
        createEntry
        updateEntry)

      attr_accessor_initialize :site, :email, :content_entry_service

      def run(script, params = {}, liquid_context)
        context = Duktape::Context.new

        define_built_in_functions(context, liquid_context)

        context.exec_string <<-JS
          function locomotiveAction(site, params) {
            #{script}
          }
        JS

        context.call_prop('locomotiveAction', site.as_json, params)
      end

      private

      def define_built_in_functions(context, liquid_context)
        BUILT_IN_FUNCTIONS.each do |name|
          context.define_function name, &send(:"#{name.underscore}_lambda", liquid_context)
        end
      end

      def send_email_lambda(liquid_context)
        -> (options) { email.send_email(options, liquid_context) }
      end

      def get_prop_lambda(liquid_context)
        -> (name) { liquid_context[name].as_json }
      end

      def send_prop_lambda(liquid_context)
        -> (name, value) { liquid_context[name] = value }
      end

      def get_session_prop_lambda(liquid_context)
        -> (name) { liquid_context.registers[:session][name.to_sym].as_json }
      end

      def set_session_prop_lambda(liquid_context)
        -> (name, value) { liquid_context.registers[:session][name.to_sym] = value }
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

    end

  end
end
