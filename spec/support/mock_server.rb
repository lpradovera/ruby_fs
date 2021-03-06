# encoding: utf-8

MockServer = Class.new

class ServerMock
  include Celluloid::IO

  finalizer :finalize

  def initialize(host, port, mock_target = MockServer.new)
    @server = TCPServer.new host, port
    @mock_target = mock_target
    @clients = []
    async.run
  end

  def finalize
    Logger.debug "ServerMock finalizing"
    @server.close if @server
    @clients.each(&:close)
  end

  def run
    after(1) { terminate }
    loop { async.handle_connection @server.accept }
  end

  def handle_connection(socket)
    @clients << socket
    _, port, host = socket.peeraddr
    Logger.debug "MockServer Received connection from #{host}:#{port}"
    loop { receive_data socket.readpartial(4096) }
  rescue EOFError
    Logger.debug "Connection from #{host}:#{port} closed"
  end

  def receive_data(data)
    Logger.debug "ServerMock receiving data: #{data}"
    @mock_target.receive_data data, self
  end

  def send_data(data)
    @clients.each { |client| client.write data }
  end
end
