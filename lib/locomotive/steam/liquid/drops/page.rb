module Locomotive
  module Steam
    module Liquid
      module Drops
        class Page < I18nBase

          delegate :fullpath, :depth, :seo_title, :meta_keywords, :meta_description, :redirect_url, :handle, to: :@_source
          delegate :listed?, :published?, :redirect?, :is_layout?, :templatized?, to: :@_source

          def title
            title =  @_source.templatized? ? @context['entry'].try(:_label) : nil
            title || @_source.title
          end

          def slug
            slug = @_source.templatized? ? @context['entry'].try(:_slug).try(:singularize) : nil
            slug || @_source.slug
          end

          def original_title
            @_source.title
          end

          def original_slug
            @_source.slug
          end

          def parent
            @parent ||= repository.parent_of(@_source).to_liquid
          end

          def breadcrumbs
            @breadcrumbs ||= liquify(*repository.ancestors_of(@_source))
          end

          def children
            @children ||= liquify(*repository.children_of(@_source))
          end

          def content_type
            if @_source.templatized?
              # content_type can be either the slug of a content type or a content type
              content_type = content_type_repository.find(@_source.content_type_id)
              ContentEntryCollection.new(content_type)
            else
              nil
            end
          end

          def editable_elements
            @editable_elements_hash ||= build_editable_elements_hash
          end

          private

          def repository
            @context.registers[:services].repositories.page
          end

          def content_type_repository
            @context.registers[:services].repositories.content_type
          end

          def build_editable_elements_hash
              {}.tap do |hash|
                repository.editable_elements_of(@_source).each do |el|
                  safe_slug = el.slug.parameterize.underscore
                  keys      = el.block.try(:split, '/').try(:compact) || []

                  _hash = _build_editable_elements_hashes(hash, keys)

                  _hash[safe_slug] = el.content
                end
              end
            end

            def _build_editable_elements_hashes(hash, keys)
              _hash = hash

              keys.each do |key|
                safe_key = key.parameterize.underscore

                _hash[safe_key] = {} if _hash[safe_key].nil?

                _hash = _hash[safe_key]
              end

              _hash
            end

        end
      end
    end
  end
end
