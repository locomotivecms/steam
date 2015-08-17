module Locomotive
  module Steam
    module Liquid
      module Filters
        module Json

          def json(input, fields = nil)
            if fields && fields.is_a?(String)
              fields = fields.split(',').map(&:strip)
            end

            if fields.blank?
              input.to_json
            elsif input.respond_to?(:each)
              if fields.size == 1
                input.map { |object| object[fields.first].to_json }.join(',')
              else
                input.map { |object| "{" + object_to_json(object, fields) + "}" }.join(',')
              end
            else
              object_to_json(input, fields)
            end
          end

          protected

          def object_to_json(input, fields)
            [].tap do |output|
              fields.each do |field|
                output << %("#{field}":#{input[field].to_json})
              end
            end.join(',')
          end

        end

        ::Liquid::Template.register_filter(Json)

      end
    end
  end
end
