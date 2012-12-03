require_relative './threadpool'

begin
  server = if ARGV[0] && Integer(ARGV[0])
    MemCache::ThreadPoolServer.new Integer(ARGV[0])
  else
    MemCache::ThreadPoolServer.new
  end
rescue ArgumentError
  $stderr.puts "Invalid port number!"
  exit 1
end

server.run
