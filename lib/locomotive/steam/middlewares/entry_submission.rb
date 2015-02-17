module Locomotive::Steam
  module Middlewares

    # Submit a content entry and persist it
    #
    class EntrySubmission < ThreadSafe

      include Helpers

      HTTP_REGEXP             = /^https?:\/\//o
      ENTRY_SUBMISSION_REGEXP = /^\/entry_submissions\/(\w+)/o
      SUBMITTED_TYPE_PARAM    = 'submitted_type_slug'
      SUBMITTED_PARAM         = 'submitted_entry_slug'

      def _call
        if slug = get_content_type_slug
          # we didn't go through the locale middleware yet,
          # so set the locale manually. Needed to build a localized
          # version of the entry + error messages (if present).
          with_locale do
            entry = create_entry(slug)
            navigation_behavior(entry)
          end
        else
          fetch_entry
        end
      end

      # Render or redirect depending on:
      # - the status of the content entry (valid or not)
      # - the presence of a callback or not
      # - the type of response asked by the browser (html or json)
      #
      def navigation_behavior(entry)
        if entry.errors.empty?
          navigation_success(entry)
        else
          navigation_error(entry)
        end
      end

      def navigation_success(entry)
        if html?
          redirect_to success_location(entry_to_query_string(query))
        elsif json?
          json_response(entry)
        end
      end

      def navigation_error(entry)
        if html?
          navigation_html_error(entry)
        elsif json?
          json_response(entry, 422)
        end
      end

      def navigation_html_error(entry)
        if error_location =~ HTTP_REGEXP
          redirect_to error_location
        else
          env['PATH_INFO'] = error_location
          store_in_liquid(entry)
          self.next
        end
      end

      private

      def store_in_liquid(entry)
        liquid_assigns[entry.content_type_slug.singularize] = entry
      end

      def entry_to_query_string(entry)
        type, slug = entry.content_type_slug, entry._slug
        "#{SUBMITTED_TYPE_PARAM}=#{type}&#{SUBMITTED_PARAM}=#{slug}"
      end

      def with_locale(&block)
        locale = default_locale || params[:locale]

        if path =~ /^\/(#{site.locales.join('|')})+(\/|$)/
          locale = $1
        end

        services.current_locale = locale

        I18n.with_locale(locale, &block)
      end

      def success_location(query); location(:success, query); end
      def error_location; location(:error); end

      def location(state, query = '')
        location = params[:"#{state}_callback"] || (entry_submissions_path? ? '/' : request.path_info)

        if query.blank?
          location
        else
          location += (location.include?('?') ? '&' : '?') + query
        end
      end

      def entry_submissions_path?
        !(request.path_info =~ ENTRY_SUBMISSION_REGEXP).nil?
      end

      # Get the slug (or permalink) of the content type either from the PATH_INFO variable (old way)
      # or from the presence of the content_type_slug param (model_form tag).
      #
      def get_content_type_slug
        if request.post? && (request.path_info =~ ENTRY_SUBMISSION_REGEXP || params[:content_type_slug])
          $1 || params[:content_type_slug]
        end
      end

      # Create a content entry with a minimal validation.
      #
      # @param [ String ] slug The slug (or permalink) of the content type
      #
      #
      def create_entry(slug)
        attributes = self.params[:entry] || self.params[:content] || {}

        if entry = services.entry_submission.submit(slug, attributes)
          entry
        else
          raise "Unknown content type '#{slug}'"
        end
      end

      # Get the content entry from the params.
      #
      def fetch_entry
        if type_slug = params[SUBMITTED_TYPE_PARAM] && slug = params[SUBMITTED_PARAM]
          if entry = services.entry_submission.find(type_slug, slug)
            store_in_liquid(entry)
          end
        end
      end

      # Build the JSON response
      #
      # @param [ Integer ] status The HTTP return code
      #
      # @return [ Array ] The rack response depending on the validation status and the requested format
      #
      def json_response(entry, status = 200)
        json = services.entry_submission.to_json(entry)
        [status, { 'Content-Type' => 'application/json' }, [json]]
      end

    end

  end
end
