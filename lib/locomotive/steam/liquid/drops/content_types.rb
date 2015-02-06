module Locomotive
  module Steam
    module Liquid
      module Drops
        class ContentTypes < ::Liquid::Drop

          def before_method(meth)
            repository = @context.registers[:services].repositories.content_type

            if content_type = repository.by_slug(meth.to_s)
              ContentTypeProxyCollection.new(content_type)
            else
              nil
            end
          end

        end

        class ContentTypeProxyCollection < ProxyCollection

          def initialize(content_type)
            @content_type = content_type
            super(nil)
          end

          def public_submission_url
            services.url_builder.public_submission_url_for(@content_type)
          end

          def api
            Locomotive::Common::Logger.warn "[Liquid template] the api for content_types has been deprecated and replaced by public_submission_url instead."
            { 'create' => public_submission_url }
          end

          def before_method(meth)
            if (meth.to_s =~ /^group_by_(.+)$/) == 0
              repository.group_by_select_option(@content_type, $1)
            elsif (meth.to_s =~ /^(.+)_options$/) == 0
              repository.select_options(@content_type, $1)
            else
              Locomotive::Common::Logger.warn "[Liquid template] trying to call #{meth} on a content_type object"
              nil
            end
          end

          protected

          def services
            @context.registers[:services]
          end

          def repository
            services.repositories.content_entry
          end

          def collection
            repository.all(@content_type, @context['with_scope'])
          end

        end

      end
    end
  end
end
