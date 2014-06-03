module Locomotive
  module Steam
    module Utils
      class LocalizedTree

        def initialize(entries, extensions)
          @entries = entries
          @extensions = extensions
        end

        def to_hash
          group_by(locale_regexp)
        end


        private

        def group_by(regexp)
          @entries.each_with_object({}) do |entry, hsh|
            file, key, subkey, *_ = regexp.match(entry).to_a
            next unless file
            (hsh[key] ||= {})[subkey.try(:to_sym) || :default] = file
          end
        end

        def locale_regexp
          /\A(.+?)(?:\.(.{2})){0,1}\.(?:(#{@extensions.join('|')})\.*)+\Z/
        end

      end
    end
  end
end
