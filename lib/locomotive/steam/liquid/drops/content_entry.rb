module Locomotive
  module Steam
    module Liquid
      module Drops
        class ContentEntry < Base
          extend Forwardable

          def_delegators :@_source, :seo_title, :meta_keywords, :meta_description

          def _label
            @_label ||= @_source._label
          end

          def _permalink
            @_source._permalink.try(:parameterize)
          end

          alias :_slug :_permalink

          def next
            self
          end

          def previous
            self
          end

          def errors
            (@_source.errors || []).inject({}) do |memo, name|
              memo[name] = ::I18n.t('errors.messages.blank')
              memo
            end
          end

          def before_method(meth)
            return '' if @_source.nil?

            if not @@forbidden_attributes.include?(meth.to_s)
              @_source.send(meth)
            else
              nil
            end
          end

        end
      end
    end
  end
end
