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

                var _gaq = _gaq || [];
                _gaq.push(['_setAccount', '#{account_id}']);
                _gaq.push(['_trackPageview']);

                (function() \{
                  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                \})();

              </script>}
          end

        end

      end
    end
  end
end
