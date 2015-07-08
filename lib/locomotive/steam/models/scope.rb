module Locomotive::Steam
  module Models

    class Scope

      attr_accessor :site, :locale, :context

      def initialize(site, locale, context = nil)
        @site, @locale, @context = site, locale, (context || {})
      end

      def default_locale
        site.try(:default_locale)
      end

      def locales
        site.try(:locales)
      end

      def apply(attributes)
        attributes['site_id'] = @site._id
      end

      def to_key
        (@site ? ['site', @site._id] : []).tap do |base|
          @context.each do |name, object|
            base << [name, object.try(:_id)]
          end
        end.flatten.join('_')
      end

    end

  end
end
