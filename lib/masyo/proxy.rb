# -*- coding: utf-8 -*-

require 'socket'

module Masyo
  class Proxy
    attr_accessor :proxy
    TIMEOUT = 3
    MAX_RECV_LEN = 1 * 1024 * 1024 * 1024

    class << self
      def run(listen_port, server_host, server_port)
        p = new(listen_port, server_host, server_port)
        p.run
      rescue Interrupt
        Masyo.logger.info "Stopping..."
        # for sending buffer to receiver before socket close.
        p.stop
      end
    end

    def initialize(listen_port, server_host, server_port)
      Masyo.logger.info "Proxy 0.0.0.0:#{listen_port} -> #{server_host}:#{server_port}"

      @server_host = server_host
      @server_port = server_port
      @proxy = ::TCPServer.new(listen_port)
    end

    def run
      loop {
        break if proxy.closed?

        Thread.start(proxy.accept) do |client|
          handle client
        end
      }
    end

    def stop
      proxy.close unless proxy.closed?
    end

    def handle client
      input = receive_from client
      response = request input
      client.write response unless response.nil?
    ensure
      client.close unless client.closed?
    end

    def request msg
      ::TCPSocket.open(@server_host, @server_port) { |socket|
        socket.write msg

        receive_from socket
      }
    rescue Errno::ECONNREFUSED
      Masyo.logger.error "Fail to request to server"
      nil
    end

    private

    def receive_from socket
      loop {
        begin
          s = socket.recv_nonblock(MAX_RECV_LEN)
        rescue ::IO::WaitReadable
          if ::IO.select([ socket ], nil, nil, TIMEOUT)
            retry
          else
            # timeout!
            break
          end
        else
          break if !s || s == "" || s == "quit"
          return s
        end
      }
    end
  end
end
