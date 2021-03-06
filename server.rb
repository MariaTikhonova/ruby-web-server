require 'socket'
require 'uri'
require 'net/http'
require 'rack'


WEB_ROOT = './public'

CONTENT_TYPE_MAPPING = {
	'html' => 'text/html',
	'txt'  => 'text/plain',
	'png'  => 'image/png',
	'jpg'  => 'image/jpeg'
}

DEFAULT_CONTENT_TYPE = 'application/octet-stream'

def content_type(path)
ext = File.extname(path).split(".").last
CONTENT_TYPE_MAPPING.fetch(ext, DEFAULT_CONTENT_TYPE)
end

def requested_file(request_line)
 request_uri = request_line.split(" ")[1]
 path        = URI.unescape(URI(request_uri).path)
 clean = []
 parts = path.split("/")
 parts.each do |part|
 	next if part.empty? || part == '.'
 	part == '..' ? clean.pop : clean << part
   end

 File.join(WEB_ROOT, *clean)
end


server = TCPServer.new('localhost', 2345)


loop do
socket = server.accept
request_line = socket.gets
STDERR.puts request_line
path = requested_file(request_line)
path = File.join(path, 'index.html') if File.directory?(path)
if File.exist?(path) && !File.directory?(path)
   File.open(path, "rb") do |file|
     socket.print "HTTP/1.1 200 OK\r\n" +
                  "HEAD / HTTP/1.1" +
                  "Content-Type: #{content_type(file)}\r\n" +
                  "Content-Length: #{file.size}\r\n" +
                  "Connection: close\r\n"

     socket.print "\r\n"

 IO.copy_stream(file, socket)
end
else
 message = "File not found\n"

 socket.print "HTTP/1.1 404 Not Found\r\n" +
              "Content-Type: text/plain\r\n" +
              "Content_Length: #{message.size}\r\n" +
              "Connection close\r\n"
 socket.print "\r\n"

 socket.print message
  socket.close
end

def head_response 
server = TCPSocket.open('localhost',2345)
server.puts "HEAD / HTTP/1.1"
server.puts "Host: localhost"
server1.puts
head = server1.gets
server1.close
status = head.scan(/\d\d\d/).first.to_i
Net::HTTP.start('localhost', 2345){|http| response = http.head(path)
 puts response
  }
end

def error_500
  if requested_file false
    message = "500 External Error\n"
  raise "HTTP/1.1 500 External Error"
  end
end

def rackapp_call

app = Proc.new do |env|
    ['200', {'Content-Type' => 'text/html'}, ['rack app.']]
end
 
Rack::Handler::WEBrick.run app
server = TCPServer.new('localhost', 2345)
status,headers,body = app.call({
  'REQUEST_METHOD' => requested_file,
  'PATH_INFO' => content_type,
  'QUERY_STRING'=> head_response 
  })
  
end


end

