# -*- coding: utf-8 -*-

require 'socket'

module Masyo
  class Client
    def initialize(host, port, buffer)
      @host = host
      @port = port
      @buffer = buffer

      if buffer.maxlen > 0
        extend BufferedClient 
      else
        extend PlainClient 
      end
    end

    extend ::Forwardable
    def_delegators :Masyo, :logger
  end

  module PlainClient
    def post(msg)
      ::TCPSocket.open(@host, @port) { |socket|
        socket.write msg
      }
    end
  end

  module BufferedClient
    def post(msg)
      ::TCPSocket.open(@host, @port) { |socket|
        begin
          buffer << msg
        rescue BufferOverflowException
          # clear buffer
          socket.write buffer.take!
          begin
            buffer << msg
          rescue BufferOverflowException
            # post without using buffer
            #
            socket.write msg
          end
        end
      }
    end
  end
end
