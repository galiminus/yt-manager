module YtManager
  class Config
    def initialize(path:)
      @path = path
    end

    def run
      system(ENV["EDITOR"] || "vi", @path)
    end
  end
end
