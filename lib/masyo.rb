#!/usr/bin/env ruby

require 'socket'
require 'fcntl'
require 'logger'

require 'masyo/server'

module Masyo
  extend self

  attr_reader :target_host, :target_port

  def run(options)
    @target_host = options[:target_host]
    @target_port = options[:target_port].to_i
    port = options[:port].to_i

    Thread.abort_on_exception = true

    Server.open(port) do |server|
      logger.info "listen #{port} port."

      server.on_read { |msg| server.post msg }
      server.awake
    end
  end

  def logger
    @logger ||= Logger.new(STDOUT)
  end
end
