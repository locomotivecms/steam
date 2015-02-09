module Locomotive
  module Steam
    module Liquid
      module Tags

        class Hybrid < ::Liquid::Block

          class HybridTagDetectedException < Exception; end

          def parse_body(body, tokens)
            body.parse(tokens, options) do |end_tag_name, end_tag_params|
              @blank &&= body.blank?

              return false if end_tag_name == block_delimiter
              unless end_tag_name
                # tag never closed
                raise HybridTagDetectedException.new
              end

              # this tag is not registered with the system
              # pass it to the current block for special handling or error reporting
              unknown_tag(end_tag_name, end_tag_params, tokens)
            end

            true
          end

          def render_as_block?
            @render_as_block
          end

          def parse(tokens)
            @render_as_block = true
            begin
              cloned_tokens = tokens.dup
              super(cloned_tokens)
              tokens.replace(cloned_tokens)
            rescue HybridTagDetectedException
              @body = nil
              @render_as_block = false
            end
            @blank = false
          end

        end

      end
    end
  end
end
