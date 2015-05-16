module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Base < ::Liquid::Block

            Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/o

            attr_accessor :slug

            def initialize(tag_name, markup, options)
              if markup =~ Syntax
                @slug             = $1.gsub(/[\"\']/, '')
                @element_options  = { fixed: false }
                markup.scan(::Liquid::TagAttributes) { |key, value| @element_options[key.to_sym] = value.gsub(/^[\"\']/, '').gsub(/[\"\']$/, '') }
              else
                raise ::Liquid::SyntaxError.new("Valid syntax: #{tag_name} <slug>(, <options>)")
              end

              super
            end

            def parse(tokens)
              super.tap do
                ActiveSupport::Notifications.instrument("steam.parse.editable.#{@tag_name}", page: options[:page], attributes: default_element_attributes)
              end
            end

            def render(context)
              service   = context.registers[:services].editable_element
              page      = context.registers[:page]
              block     = context['block'].try(:name)

              if element = service.find(page, block, @slug)
                render_element(context, element)
              else
                # Locomotive::Common::Logger.error "[#{page.fullpath}] missing #{@tag_name} \"#{@slug}\" (#{context['block'].try(:name) || 'default'})"
                super
              end
            end

            protected

            def default_element_attributes
              {
                block:          self.current_inherited_block_name,
                slug:           @slug,
                hint:           @element_options[:hint],
                priority:       @element_options[:priority] || 0,
                fixed:          !!@element_options[:fixed],
                disabled:       false,
                inline_editing: true,
                from_parent:    false,
                type:           @tag_name.to_sym
              }
            end

            def current_inherited_block_name
              @element_options[:block] || current_inherited_block.try(:name)
            end

            def current_inherited_block
              options[:inherited_blocks].try(:[], :nested).try(:last)
            end

            def render_default_content
              begin
                if nodelist.all? { |n| n.is_a? String }
                  @body.render(::Liquid::Context.new)
                else
                  raise ::Liquid::SyntaxError.new("No liquid tags are allowed inside the #{@tag_name} \"#{@slug}\" (block: #{current_inherited_block_name || 'default'})")
                end
              end
            end

            #:nocov:
            def render_element(element)
              raise 'FIXME: has to be overidden'
            end

          end

        end
      end
    end
  end
end
