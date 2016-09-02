module Locomotive
  module Steam
    module Liquid
      module Filters
        module Resize

          # Optional args include:
          #   quality: <number> compress image
          #   auto_orient: <true|false> fix EXIF orientation issues
          #   strip: <true|false> remove extra possibly unnecessary metadata
          #   progressive: <true|false> make JPEG progressive
          #   optimize: <number> shortcut to quality: and also applies strip and progressive
          #   filters: <string> access to any ImageMagick arguments 
          def resize(input, resize_string, *args)
            args ||= {}
            options = []

            args.flatten.each do |arg|
              arg.each do |k, v|
                options << case k.to_sym
                when :quality
                  "-quality #{v}"
                when :optimize # Shortcut helper to set quality, progressive and strip
                  "-quality #{v} -strip -interlace Plane"
                when :auto_orient
                  "-auto-orient" if v
                when :strip
                  "-strip" if v
                when :progressive
                  "-interlace Plane" if v
                when :filters
                  v
                else
                  next
                end
              end
            end

            @context.registers[:services].image_resizer.resize(input, resize_string, options.join(' '))
          end

        end

        ::Liquid::Template.register_filter(Resize)

      end
    end
  end
end
