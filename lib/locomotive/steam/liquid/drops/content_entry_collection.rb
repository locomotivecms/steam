module Locomotive
  module Steam
    module Liquid
      module Drops

        class ContentEntryCollection < ::Liquid::Drop

          delegate :first, :last, :each, :each_with_index, :empty?, :any?, to: :collection

          def initialize(content_type, repository = nil)
            @content_type = content_type
            @repository   = repository
          end

          def all
            collection.map do |entry|
              entry.to_liquid.tap do |drop|
                if drop && drop.respond_to?(:context=)
                  drop.context = @context
                end
              end
            end
          end

          def count
            repository.count(conditions)
          end

          alias :size   :count
          alias :length :count

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
              content_type_repository.select_options(@content_type, $1)
            else
              Locomotive::Common::Logger.warn "[Liquid template] trying to call #{meth} on a content_type object"
              nil
            end
          end

          protected

          def slice(index, length)
            repository.all(conditions) { offset(index).limit(length) }
          end

          def collection
            @collection ||= repository.all(conditions)
          end

          def conditions
            _slug = (@context['with_scope_content_type'] ||= @content_type.slug)
            _slug == @content_type.slug ? @context['with_scope'] : {}
          end

          def services
            @context.registers[:services]
          end

          def content_type_repository
            services.repositories.content_type
          end

          def repository
            @repository || services.repositories.content_entry.with(@content_type)
          end

        end

      end
    end
  end
end
