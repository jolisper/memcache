require 'socket'
require_relative './command_handler'
require_relative './cache'

module MemCache
  class ThreadPoolServer

    CONCURRENCY = 25

    Connection = Struct.new(:client) do
      CRLF = "\r\n"
      
      def gets
        begin
          client.gets(CRLF)
        rescue Errno::ECONNRESET, Errno::EPIPE, IOError => e
          $stderr.puts "Error in gets: " + e.class.name + " " + e.message
        end
      end
      
      def respond(message)
        client.write(message)
        client.write(CRLF)
        rescue Errno::ECONNRESET, Errno::EPIPE => e
          $stderr.puts "Error in respond " + e.class.name + " " + e.message
      end
      
      def close
        client.close
      end

    end

    def initialize(port = 5544)
      @server = TCPServer.new(port)
      @cache = Cache.new
      trap(:INT) { exit }
    end
    
    def run
      Thread.abort_on_exception = true
      threads = ThreadGroup.new
      
      CONCURRENCY.times do
        threads.add spawn_thread
      end
      
      $stdout.puts "Memcache Server v0.0.1 is running: pid=#{$$} port=#{@server.addr[1]} threads=#{CONCURRENCY}"
      
      sleep
    end
    
    def spawn_thread
      Thread.new do
        loop do
          conn = Connection.new(@server.accept)
          
          handler = CommandHandler.new(conn, @cache)
          
          catch(:conn_close) do
            loop do
              request = conn.gets
              throw :conn_close unless request
              handler.handle(request)
            end
          end

          conn.close
        end
      end
    end
    
  end
end
