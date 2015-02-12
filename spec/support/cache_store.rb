class NoCacheStore
  def fetch(name, options = nil, &block); yield; end
end
