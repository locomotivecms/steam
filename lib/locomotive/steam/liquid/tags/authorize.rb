module Locomotive
  module Steam
    module Liquid
      module Tags

        # Redirect the current site visitor to another page if she/he
        # is not authenticated.
        # More information about the authentication feature here:
        # https://locomotive-v3.readme.io/v3.3/docs/introduction-1
        #
        # The Liquid tag requires 2 parameters:
        # - the slug of the content type used for the authentication (a content type with a password field)
        # - the handle of the page we want the user to be redirected to if unauthenticated
        #
        # Basically the authorize tag checks if the liquid context has
        # a reference to the current authenticated content entry.
        # If not, it raises a redirection exception forcing the Steam middleware stack
        # to process a HTTP redirection.
        #
        # Example:
        #
        #   {% authorize 'accounts', 'sign_in' %}
        #
        class Authorize < ::Liquid::Tag

          Syntax = /(#{::Liquid::QuotedString}+)\s*,\s*(#{::Liquid::QuotedString}+)/o

          def initialize(tag_name, markup, options)
            if markup =~ Syntax
              @content_type_slug, @page_handle = $1.try(:gsub, /['"]/, ''), $2.try(:gsub, /['"]/, '')
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'authorize' - Valid syntax: authorize [content type slug], [page handle]")
            end

            super
          end

          def render_to_output_buffer(context, output)
            @context = context

            unless authenticated_entry = context["current_#{@content_type_slug.singularize}"]
              services.page_redirection.redirect_to(@page_handle, locale)
            end

            output
          end

          private

          def locale
            @context.registers[:locale]
          end

          def services
            @context.registers[:services]
          end

        end

        ::Liquid::Template.register_tag('authorize'.freeze, Authorize)

      end
    end
  end
end
