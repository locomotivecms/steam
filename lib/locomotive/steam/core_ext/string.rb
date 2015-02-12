unless String.public_instance_methods.include?(:to_bool)
  class String

    def to_bool
      return true if self == true || self =~ (/(true|t|yes|y|1)$/i)
      return false if self == false || self.blank? || self =~ (/(false|f|no|n|0)$/i)

      raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
    end

  end
end

unless String.public_instance_methods.include?(:permalink)
  require 'stringex'

  class String

    def permalink(underscore = false)
      # if the slug includes one "_" at least, we consider that the "_" is used instead of "-".
      _permalink = if !self.index('_').nil?
        self.to_url(replace_whitespace_with: '_')
      else
        self.to_url
      end

      underscore ? _permalink.underscore : _permalink
    end

    def permalink!(underscore = false)
      replace(self.permalink(underscore))
    end

    alias :parameterize! :permalink!

  end
end
