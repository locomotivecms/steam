module Locomotive
  module Steam
    module Liquid
      module Tags
        module Editable
          class Base < ::Liquid::Block

            include Concerns::Attributes

            Syntax = /(#{::Liquid::QuotedFragment})(\s*,\s*#{::Liquid::Expression}+)?/o

            attr_accessor :label, :slug, :page_fullpath

            def initialize(tag_name, markup, options)
              if markup =~ Syntax
                @page_fullpath    = options[:page].fullpath
                @label_or_slug    = $1.gsub(/[\"\']/, '')

                parse_attributes(markup, fixed: false, inline_editing: true)

                set_label_and_slug
              else
                raise ::Liquid::SyntaxError.new("Valid syntax: #{tag_name} <slug>(, <options>)")
              end

              super
            end

            def parse(tokens)
              super.tap do
                ActiveSupport::Notifications.instrument("steam.parse.editable.#{@tag_name}", page: options[:page], attributes: default_element_attributes)

                register_default_content
              end
            end

            alias :default_render_to_output_buffer :render_to_output_buffer

            def render_to_output_buffer(context, output)
              evaluate_attributes(context)

              service   = context.registers[:services].editable_element
              page      = fetch_page(context)
              block     = attributes[:block] || context['block'].try(:name)

              # If Steam inside Wagon (test mode), we've to let the developer know
              # that editable_**** tags don't work if the site has declared at least one section
              if context['wagon'] && context.registers[:repositories].section.count > 0
                Locomotive::Common::Logger.error "[#{page.fullpath}] You can't use editable elements whereas you declared section(s)".colorize(:red)
              end

              if element = service.find(page, block, slug)
                output << render_element(context, element)
              else
                Locomotive::Common::Logger.error "[#{page.fullpath}] missing #{@tag_name} \"#{slug}\" (#{context['block'].try(:name) || 'default'})".colorize(:yellow)
                super
              end

              output
            end

            def blank?
              false
            end

            protected

            def render_default_content
              begin
                if nodelist.all? { |n| n.is_a? String }
                  @body.render(::Liquid::Context.new)
                else
                  raise ::Liquid::SyntaxError.new("No liquid tags are allowed inside the #{@tag_name} \"#{@slug}\" (block: #{current_inherited_block_name || 'default'})")
                end
              end
            end

            def editable?(context, element = nil)
              !(
                element.try(:inline_editing) == false ||
                [false, 'false'].include?(default_element_attributes[:inline_editing]) ||
                context.registers[:live_editing].blank?
              )
            end

            def fetch_page(context)
              page = context.registers[:page]

              return page if !attributes[:fixed] || page.fullpath == page_fullpath

              pages   = context.registers[:pages] ||= {}
              service = context.registers[:services].page_finder

              pages[page_fullpath] ||= service.find(page_fullpath)
            end

            def register_default_content
              return if options[:default_editable_content].nil?

              hash  = options[:default_editable_content]
              key   = [current_inherited_block_name, @slug].compact.join('/')

              hash[key] = render_default_content
            end

            def set_label_and_slug
              @slug   = @label_or_slug
              @label  = attributes[:label]

              if attributes[:slug].present?
                @slug   = attributes[:slug]
                @label  ||= @label_or_slug
              end
            end

            def default_element_attributes
              {
                block:          self.current_inherited_block_name,
                label:          label,
                slug:           slug,
                hint:           attributes[:hint],
                priority:       attributes[:priority] || 0,
                fixed:          [true, 'true'].include?(attributes[:fixed]),
                disabled:       false,
                inline_editing: [true, 'true'].include?(attributes[:inline_editing]),
                from_parent:    false,
                type:           @tag_name.to_sym
              }
            end

            def current_inherited_block_name
              attributes[:block] || current_inherited_block.try(:name)
            end

            def current_inherited_block
              parse_context[:inherited_blocks].try(:[], :nested).try(:last)
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
