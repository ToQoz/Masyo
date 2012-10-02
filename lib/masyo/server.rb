# -*- coding: utf-8 -*-

require 'socket'
require 'masyo/event'

module Masyo
  class Server
    attr_accessor :tcp_server, :socket_to_client
    TO_CLIENT_SOCKET_TIMEOUT = 3

    class << self
      def event_types
        [ :read, :close ]
      end

      def open(*args)
        raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)" if args.size <= 0 || args.size >= 2

        server = new(args.first)
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
      raise ArgumentError, "#{port} is not a Integer" unless port.is_a? Integer
      @tcp_server = ::TCPServer.new(port)
    end

    def start
      loop {
        Thread.start(tcp_server.accept) do |to_client|
          handle_request to_client
        end
      }
    end

    def handle_request(to_client)
      begin
        loop {
          begin
            input = to_client.recv_nonblock(2048)
          rescue ::IO::WaitReadable
            if ::IO.select([ to_client ], nil, nil, TO_CLIENT_SOCKET_TIMEOUT)
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
        to_client.close_immediately unless to_client.closed?
      end
    end

    extend ::Forwardable
    def_delegators :tcp_server, :close, :closed?
    def_delegators :Masyo, :logger
  end
end
