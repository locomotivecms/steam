module Locomotive
  module Steam
    module Liquid
      module Tags

        # Consume web services as easy as pie directly in liquid!
        #
        # Usage:
        #
        # {% consume blog from 'http://nocoffee.tumblr.com/api/read.json?num=3' username: 'john', password: 'easy', format: 'json', expires_in: 3000 %}
        #   {% for post in blog.posts %}
        #     {{ post.title }}
        #   {% endfor %}
        # {% endconsume %}
        #
        class Consume < ::Liquid::Block

          include Concerns::Attributes

          Syntax = /(#{::Liquid::VariableSignature}+)\s*from\s*(#{::Liquid::QuotedFragment}+),?(.+)?/o.freeze

          attr_reader :variable_name, :url_expr, :url, :expires_in

          def initialize(tag_name, markup, options)
            super

            if markup =~ Syntax
              @variable_name, @url_expr, attributes = $1.to_s, ::Liquid::Expression.parse($2), $3

              parse_attributes(attributes)
            else
              raise ::Liquid::SyntaxError.new("Syntax Error in 'consume' - Valid syntax: consume <var> from \"<url>\" [username: value, password: value]")
            end
          end

          def render(context)
            evaluate_attributes(context)

            # attributes will become the options which will be passed to the service.
            # we don't want the expires_in option to be part of it.
            @expires_in = attributes.delete(:expires_in)&.to_i

            # the URL can come from a variable
            @url = context.evaluate(url_expr)

            if url.blank?
              Locomotive::Common::Logger.error "A consume tag can't call an empty URL."
              ''
            else
              render_all_and_cache_it(context) { |_context| super(_context) }
            end
          end

          protected

          def render_all_and_cache_it(context, &block)
            cache_service(context).fetch(page_fragment_cache_key, cache_options) do
              self.render_all_without_cache(context, &block)
            end
          end

          def render_all_without_cache(context)
            context.stack do
              begin
                Locomotive::Common::Logger.info "[consume] #{url.inspect} / #{attributes.inspect}"

                context.scopes.last[variable_name] = service(context).consume(url, attributes)
              rescue Timeout::Error, Errno::ETIMEDOUT
                context.scopes.last[variable_name] = last_response(context)
              end

              yield(context)
            end
          end

          def service(context)
            context.registers[:services].external_api
          end

          def cache_service(context)
            context.registers[:services].cache
          end

          def cache_options
            expires_in.blank? || expires_in == 0 ? { force: true } : { expires_in: expires_in }
          end

          def last_response(context)
            cache_service(context).read(page_fragment_cache_key)
          end

          def page_fragment_cache_key
            "Steam-consume-#{Digest::SHA1.hexdigest(variable_name + url)}"
          end

        end

        ::Liquid::Template.register_tag('consume'.freeze, Consume)
      end
    end
  end
end
