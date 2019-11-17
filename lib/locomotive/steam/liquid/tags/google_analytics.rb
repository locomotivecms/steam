module Locomotive
  module Steam
    module Liquid
      module Tags
        class GoogleAnalytics < ::Liquid::Tag

          Syntax = /(#{::Liquid::QuotedFragment}+)/o.freeze

          attr_reader :account_id

          def initialize(tag_name, markup, options)
            super

            if markup =~ Syntax
              @account_id = ::Liquid::Expression.parse($1)
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'google_analytics' - Valid syntax: google_analytics <account_id>")
            end
          end

          def render(context)
            ga_snippet(context.evaluate(account_id))
          end

          private

          def ga_snippet(account_id)
            %{
              <!-- Global Site Tag (gtag.js) - Google Analytics -->
              <script async src="https://www.googletagmanager.com/gtag/js?id=#{account_id}"></script>
              <script>
                window.dataLayer = window.dataLayer || [];
                function gtag(){dataLayer.push(arguments);}
                gtag('js', new Date());

                gtag('config', '#{account_id}');
              </script>
            }
          end

        end

        ::Liquid::Template.register_tag('google_analytics'.freeze, GoogleAnalytics)

      end
    end
  end
end
