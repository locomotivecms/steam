module Locomotive
  module Steam
    module Services

      class PageFinder < Struct.new(:repository)

        include Concerns::Decorator

        WILDCARD = 'content-type-template'

        def find(path)
          decorate do
            repository.by_fullpath(path)
          end
        end

        def match(path)
          decorate do
            repository.matching_fullpath(path_combinations(path))
          end
        end

        private

        def path_combinations(path)
          _path_combinations(path.split('/'))
        end

        def _path_combinations(segments, can_include_template = true)
          return nil if segments.empty?
          segment = segments.shift

          (can_include_template ? [segment, WILDCARD] : [segment]).map do |_segment|
            if (_combinations = _path_combinations(segments.clone, can_include_template && _segment != WILDCARD))
              [*_combinations].map do |_combination|
                File.join(_segment, _combination)
              end
            else
              [_segment]
            end
          end.flatten
        end

      end

    end
  end
end
