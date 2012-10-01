# -*- coding: utf-8 -*-

require 'logger'

require 'masyo/server'
require 'masyo/client'
require 'masyo/buffer'

module Masyo
  extend self

  def run(opts = {})
    opts = {
      listen_port: 2000,
      server_host: "0.0.0.0",
      server_port: 24224 ,
      buffer_size: 0
    }.merge(opts)
    Thread.abort_on_exception = true

    buffer = Buffer.new opts[:buffer_size]
    client = Client.new(opts[:server_host], opts[:server_port], buffer)
    Server.open(opts[:listen_port]) do |server|
      logger.info "listen #{opts[:listen_port]} port."

      server.on_read do |msg|
        client.post msg
      end

      server.on_close {
        client.post buffer.take!
      }

      server.start
    end
  end

  def logger
    @logger ||= Logger.new STDOUT
  end
end
