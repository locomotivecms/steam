module Locomotive
  module Steam
    module Liquid
      module Tags
        class InheritedBlock < ::Liquid::InheritedBlock

          def parse(tokens)
            super.tap do
              if listener = options[:events_listener]
                listener.emit(:inherited_block, page: options[:page], name: @name, found_super: self.contains_super?(nodelist))
              end
            end
          end

          protected

          def contains_super?(nodes)
            nodes.any? do |node|
              if is_node_block_super?(node)
                true
              elsif node.respond_to?(:nodelist) && !node.nodelist.nil? && !node.is_a?(Locomotive::Steam::Liquid::Tags::InheritedBlock)
                contains_super?(node.nodelist)
              end
            end
          end

          def is_node_block_super?(node)
            return unless node.is_a?(::Liquid::Variable)

            node.raw.strip == 'block.super'
          end

        end

        ::Liquid::Template.register_tag('block', InheritedBlock)
      end
    end
  end
end
