module Locomotive
  module Steam
    module Models
      module Concerns

        module ToJson

          def to_hash
            {}.tap do |_attributes|
              attributes.each do |key, value|
                next if value && value.respond_to?(:repository) # skip associations

                _attributes[key] = (case value
                when Locomotive::Steam::Models::I18nField then value.to_hash
                else value
                end)
              end
            end.stringify_keys
          end

          def as_json(options = nil)
            to_hash.as_json(options)
          end

          def to_json
            as_json.to_json
          end

        end

      end
    end
  end
end
