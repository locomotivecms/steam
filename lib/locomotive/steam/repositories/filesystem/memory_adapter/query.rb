require 'forwardable'

module Locomotive
  module Steam
    module Repositories
      module Filesystem
        module MemoryAdapter

          class Query

            include Enumerable
            extend  Forwardable

            def_delegators :all, :each, :to_s, :to_a, :empty?, :size

            alias :length :size
            alias :count :size

            attr_reader :conditions

            def initialize(dataset, locale=nil, &block)
              @dataset    = dataset
              @conditions = []
              @sorting    = nil
              @limit      = nil
              @offset     = 0
              @locale     = locale
              instance_eval(&block) if block_given?
            end

            def where(conditions = {})
              @conditions += conditions.map { |name, value| Condition.new(name, value, @locale) }
              self
            end

            def +(query)
              @conditions += query.conditions
              self
            end

            def order_by(order_string)
              @sorting = order_string.downcase.split.map(&:to_sym) unless order_string.empty?
              self
            end

            def limit(num)
              @limit = num
              self
            end

            def offset(num)
              @offset = num
              self
            end

            def ==(other)
              if other.kind_of? Array
                all == other
              else
                super
              end
            end

            def all
              limited sorted(filtered)
            end

            def sorted(entries)
              return entries if @sorting.nil?

              name, direction  = @sorting.first, (@sorting.last || :asc)
              if direction == :asc
                entries.sort { |a, b| a.send(name) <=> b.send(name) }
              else
                entries.sort { |a, b| b.send(name) <=> a.send(name) }
              end
            end

            def limited(entries)
              return [] if @limit == 0
              return entries if @offset == 0 && @limit.nil?

              subentries = entries.drop(@offset || 0)
              if @limit.kind_of? Integer
                subentries.take(@limit)
              else
                subentries
              end
            end

            def filtered
              @dataset.to_a.dup.find_all do |entry|
                accepted = true

                @conditions.each do |_condition|
                  unless _condition.matches?(entry)
                    accepted = false
                    break # no to go further
                  end
                end
                accepted
              end
            end # filtered

          end
        end
      end
    end
  end
end
