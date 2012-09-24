# -*- coding: utf-8 -*-

require 'logger'

require 'masyo/server'
require 'masyo/buffer'

module Masyo
  extend self

  attr_accessor :target_host, :target_port, :port, :buffer_size, :server

  def run(opts)
    configure opts
    Thread.abort_on_exception = true

    Server.open(port) do |server|
      logger.info "listen #{port} port."

      server.on_read do |msg|
        if buffer_size <= 0
          server.post msg
        else
          begin
            buffer << msg
          rescue BufferOverflowException
            # clear buffer
            server.post buffer.take!
            begin
              buffer << msg
            rescue BufferOverflowException
              # post without using buffer
              server.post msg
            end
          end
        end
      end

      server.on_close {
        server.post buffer.take!
      }

      server.awake
    end
  end

  def configure(opts)
    opts.each_pair  do |o_key, o_value|
      self.send("#{o_key}=", o_value) if self.respond_to?("#{o_key}=")
    end
  end

  def buffer
    @buffer ||= Buffer.new buffer_size
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
