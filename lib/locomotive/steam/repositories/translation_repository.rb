module Locomotive
  module Steam

    class TranslationRepository

      include Models::Repository

      # Entity mapping
      mapping :translations, entity: Translation

      def group_by_key
        all { only(:key, :values) }.inject({}) do |memo, translation|
          memo[translation.key] = translation.values
          memo
        end
      end

      def by_key(key)
        first { where(key: key) }
      end

    end
  end
end
