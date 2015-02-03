module Locomotive
  module Steam
    module Liquid
      module Tags

        class Snippet < ::Liquid::Include

          def parse(tokens)
            if listener = options[:events_listener]
              listener.emit(:include, page: options[:page], name: @template_name)

              # look for editable elements
              if snippet = find_snippet(options[:repositories].snippet, @template_name)
                ::Liquid::Template.parse(snippet, options.merge(snippet: @template_name))
              end
            end
          end

          private

          def read_template_from_file_system(context)
            snippet = find_snippet(context.registers[:repositories].snippet, @template_name)

            raise SnippetNotFound.new("Snippet with slug '#{@template_name}' was not found") if snippet.nil?

            snippet.source
          end

          def find_snippet(repository, slug)
            repository.by_slug(slug)
          end

        end

        ::Liquid::Template.register_tag('include'.freeze, Snippet)
      end
    end
  end
end
