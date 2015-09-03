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
              <script type="text/javascript">
                (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
                (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
                m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
                })(window,document,'script','//www.google-analytics.com/analytics.js','ga');
                ga('create', '#{account_id}', 'auto');
                ga('send', 'pageview');
              </script>
            }
          end

        end

      end
    end
  end
end
