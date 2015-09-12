module Locomotive
  module Steam
    module Liquid
      module Filters
        module Json

          def json(input, fields = [])
            if fields && fields.is_a?(String)
              fields = fields.split(',').map(&:strip)
            end

            if input.respond_to?(:each)
              '[' + input.map do |object|
                fields.size == 1 ? object[fields.first].to_json : object_to_json(object, fields)
              end.join(',') + ']'
            else
              object_to_json(input, fields)
            end
          end

          # without the leading and trailing braces/brackets
          # useful to add a prperty to an object or an element to an array
          def open_json(input)
            if input =~ /\A[\{\[](.*)[\}\]]\Z/m
              $1
            else
              input
            end
          end

          protected

          def object_to_json(input, fields)
            if input.respond_to?(:as_json)
              options = fields.blank? ? {} : { only: fields }
              input.as_json(options).to_json
            else
              input.to_json
            end
          end

        end

        ::Liquid::Template.register_filter(Json)

      end
    end
  end
end
