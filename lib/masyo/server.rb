# -*- coding: utf-8 -*-

require 'socket'
require 'masyo/event'

module Masyo
  class Server
    attr_accessor :tcp_server
    CLIENT_SOCKET_TIMEOUT = 3

    class << self
      def event_types
        [ :read, :close ]
      end

      def open(*args)
        port = args.first
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)" if args.size <= 0
        raise ArgumentError, "#{port} is not a Integer" unless port.is_a? Integer

        server = new(port)
        return server unless block_given?
        begin
          yield server
        ensure
          # for sending buffer to server before socket close.
          server.trigger_event :close
          server.close unless server.closed?
        end
      end
    end

    include Event

    def initialize(port)
      @tcp_server = TCPServer.new(port)
    end

    def post(msg)
      Masyo.logger.info msg

      TCPSocket.open(Masyo.target_host, Masyo.target_port) { |socket|
        Masyo.logger.info "Succeed TCPSocket.open. `#{Masyo.target_host}:#{Masyo.target_port}`"

        socket.puts msg
      } rescue Masyo.logger.error "Failed TCPSocket.open. `#{Masyo.target_host}:#{Masyo.target_port}`"
    end

    def awake
      loop {
        Thread.start(tcp_server.accept) do |c|
          handle_client c
        end
      }
    end

    def handle_client(client)
      begin
        loop {
          begin
            input = client.recv_nonblock(Masyo.buffer_size > 1000 ? Masyo.buffer_size : 1000)
          rescue IO::WaitReadable
            if IO.select([ client ], nil, nil, CLIENT_SOCKET_TIMEOUT)
              retry
            else
              # timeout!
              break
            end
          else
            break if !input || input == "" || input == "quit"

            trigger_event :read, input
          end
        }
      ensure
        linger = [1,0].pack('ii')
        client.setsockopt(Socket::SOL_SOCKET, Socket::SO_LINGER, linger)
        client.close unless client.closed?
      end
    end

    extend Forwardable
    def_delegators :tcp_server, :close, :closed?
  end
end
