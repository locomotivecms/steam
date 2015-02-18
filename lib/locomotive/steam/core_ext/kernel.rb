module Kernel

  def require_relative_all(paths, sub = nil)
    main_path = File.dirname(caller.first.sub(/:\d+$/, ''))
    main_path = File.join(main_path, sub) if sub

    [*paths].each do |path|
      Dir[File.join(main_path, path, '*.rb')].each { |file| require file }
    end
  end

end


