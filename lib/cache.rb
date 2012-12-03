module MemCache
  class Cache
    include Enumerable

    def initialize
      @cache = {}
      @lock = Mutex.new
    end
    
    def set(key, value)
      @lock.synchronize {
        @cache[key] = value
      }
    end

    def get(key)
      @cache[key]
    end
    
    def remove(key)
      @lock.synchronize {
        @cache.delete key
      }
    end 

    def each &block
      @cache.each { |i| block.call i }
    end

    def size
      @cache.size
    end
    
  end
end
