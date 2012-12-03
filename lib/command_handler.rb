module MemCache
  class CommandHandler
   
    def initialize(conn, cache)
      @conn = conn
      @cache = cache
    end

    def handle(data)
      command, key, value = data.strip.split
      
      if command 
        case command.upcase
        when 'SET'
          @cache.set(key, value)
          @conn.respond "STORED"
        when 'GET'
          @conn.respond "VALUE #{@cache.get(key)}"
        when 'LIST'
          @cache.each do |key, value|
            @conn.respond "TUPLE #{key} #{value}"
          end
        when 'SIZE'
          @conn.respond "TUPLES #{@cache.size}"
        when 'QUIT'
          @conn.respond "QUIT"
          throw(:conn_close)
        when 'REMOVE'
          @cache.remove key
          @conn.respond 'REMOVED'
        else
          @conn.respond 'UNKNOWN'
        end
      end
      
    end

  end
end
