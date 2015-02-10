# Big thanks to Tim Ruffles (https://github.com/timruffles)
# https://gist.github.com/timruffles/2780508
module HashConverter
  class << self

    def to_underscore(hash)
      convert(hash, :underscore)
    end

    def to_string(hash)
      convert(hash, :to_s)
    end

    def to_sym(hash)
      convert(hash, :to_sym)
    end

    # FIXME: not sure it will be ever needed
    # def to_camel_case hash
    #   convert hash, :camelize, :lower
    # end

    def convert(obj, *method)
      case obj
      when Hash
        obj.inject({}) do |h, (k,v)|
          v = convert(v, *method)
          h[k.send(*method)] = v
          h
        end
      when Array
        obj.map { |m| convert(m, *method) }
      else
        obj
      end
    end

  end
end
