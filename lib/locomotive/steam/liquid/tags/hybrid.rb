module Locomotive
  module Steam
    module Liquid
      module Tags

        class Hybrid < ::Liquid::Block

          def render_as_block?
            @render_as_block
          end

          def parse(tokens)
            if @render_as_block = find_block_delimiter?(tokens)
              super
            else
              @body  = nil
              @blank = false
            end
          end

          def find_block_delimiter?(tokens)
            tokens.each do |token|
              next if token.empty?
              if token.start_with?(::Liquid::BlockBody::TAGSTART)
                if token =~ ::Liquid::BlockBody::FullToken
                  return false  if $1 == @tag_name
                  return true   if $1 == block_delimiter
                end
              end
            end
            false
          end

        end

      end
    end
  end
end
