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
                @page_fullpath    = options[:page].fullpath
                @slug             = $1.gsub(/[\"\']/, '')
                @element_options  = { fixed: false, inline_editing: true }
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

            alias :default_render :render

            def render(context)
              service   = context.registers[:services].editable_element
              page      = fetch_page(context)
              block     = @element_options[:block] || context['block'].try(:name)

              if element = service.find(page, block, @slug)
                render_element(context, element)
              else
                Locomotive::Common::Logger.error "[#{page.fullpath}] missing #{@tag_name} \"#{@slug}\" (#{context['block'].try(:name) || 'default'})"
                super
              end
            end

            protected

            def fetch_page(context)
              page = context.registers[:page]

              return page if !@element_options[:fixed] || page.fullpath == @page_fullpath

              pages   = context.registers[:pages] ||= {}
              service = context.registers[:services].page_finder

              pages[@page_fullpath] ||= service.find(@page_fullpath)
            end

            def default_element_attributes
              {
                block:          self.current_inherited_block_name,
                slug:           @slug,
                hint:           @element_options[:hint],
                priority:       @element_options[:priority] || 0,
                fixed:          [true, 'true'].include?(@element_options[:fixed]),
                disabled:       false,
                inline_editing: [true, 'true'].include?(@element_options[:inline_editing]),
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
