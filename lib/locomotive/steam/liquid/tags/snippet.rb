module Locomotive
  module Steam
    module Liquid
      module Tags

        class Snippet < ::Liquid::Include

          attr_reader :template_name

          def initialize(tag_name, markup, options)
            super

            if markup =~ Syntax
              @template_name = $1
            end
          end

          def parse(tokens)
            ActiveSupport::Notifications.instrument('steam.parse.include', page: parse_context[:page], name: template_name)

            # look for editable elements (only used by the Engine)
            # In the next version of Locomotive (v5), we won't support the editable elements
            #
            # NOTE: it doesn't support dynamically choosen template
            #
            if parse_context[:snippet_finder] && snippet = parse_context[:snippet_finder].find(template_name)
              parse_context[:parser]._parse(snippet, parse_context.merge(snippet: template_name))
            end
          end

          def render(context)
            # parse_context (previously @options) doesn't include the page key if cache is on
            parse_context[:page] = context.registers[:page]

            begin
              super
            rescue ::Liquid::ArgumentError
              # NOTE: Locomotive site developers should always use quotes (or doubles quotes) for the name of a snippet.
              # Unfortunately, a lot of sites don't use them. So here is a little patch to not break those sites.
              Locomotive::Common::Logger.warn("Use quotes if the name of your snippet (#{template_name}) is not dynamic.")

              @template_name_expr = template_name

              super
            end
          end

          private

          def read_template_from_file_system(context)
            file_system = context.registers[:file_system] || Liquid::Template.file_system

            # we use a convention to differentiate sections from snippets
            template_path = "snippets--#{context.evaluate(@template_name_expr)}"

            file_system.read_template_file(template_path)
          end

        end

        ::Liquid::Template.register_tag('include'.freeze, Snippet)
      end
    end
  end
end
