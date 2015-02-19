module Locomotive::Steam::Middlewares

  class StackProxy

    attr_reader :list, :operations

    def initialize(&block)
      @list = []
      instance_eval(&block) if block_given?
    end

    def use(*args, &block)
      @list << [args, block]
    end

    def insert_before(index, *args, &block)
      @list.insert(index_of(index), [args, block])
    end

    def insert_after(index, *args, &block)
      @list.insert(index_of(index) + 1, [args, block])
    end

    def delete(index)
      @list.delete_at(index_of(index))
    end

    alias :insert :insert_before

    def inject(builder)
      @list.each do |args|
        builder.use(*(args[0]), &args[1])
      end
    end

    def index_of(index)
      if index.is_a?(Integer)
        index
      else
        @list.index { |args| args[0][0] == index }
      end
    end

  end

end
