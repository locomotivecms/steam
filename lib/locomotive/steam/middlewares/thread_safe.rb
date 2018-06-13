module Locomotive::Steam::Middlewares

  class ThreadSafe

    attr_accessor_initialize :app
    attr_accessor :env

    def call(env)
      threadsafed     = dup
      threadsafed.env = env

      threadsafed._call

      threadsafed.next
    end

    def next
      # avoid to be called twice
      @next_response || (@next_response = app.call(env))
    end

  end

end
