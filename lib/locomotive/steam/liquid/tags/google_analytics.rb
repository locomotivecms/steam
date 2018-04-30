module Locomotive
  module Steam
    module Liquid
      module Tags
        class GoogleAnalytics < ::Solid::Tag

          tag_name :google_analytics

          def display(account_id = nil)
            if account_id.blank?
              raise ::Liquid::SyntaxError.new("Syntax Error in 'google_analytics' - Valid syntax: google_analytics <account_id>")
            else
              ga_snippet(account_id)
            end
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

      end
    end
  end
end
