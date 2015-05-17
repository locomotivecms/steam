module Locomotive
  module Steam
    module Liquid
      module Tags
        class InheritedBlock < ::Liquid::InheritedBlock

          def parse(tokens)
            super.tap do
              ActiveSupport::Notifications.instrument("steam.parse.inherited_block", page: options[:page], name: @name, found_super: self.contains_super?(nodelist))
            end
          end

          protected

          def contains_super?(nodes)
            nodes.any? do |node|
              if is_node_block_super?(node)
                true
              elsif is_node_with_nodelist?(node)
                contains_super?(node.nodelist)
              end
            end
          end

          def is_node_block_super?(node)
            return unless node.is_a?(::Liquid::Variable)

            node.raw.strip == 'block.super'
          end

          def is_node_with_nodelist?(node)
            if node.respond_to?(:nodelist) && !node.is_a?(Locomotive::Steam::Liquid::Tags::InheritedBlock)
              # some blocks does not have a body like the link_to tag
               _nodelist = node.nodelist rescue nil
               !_nodelist.nil?
            end
          end

        end

        ::Liquid::Template.register_tag('block'.freeze, InheritedBlock)
      end
    end
  end
end
