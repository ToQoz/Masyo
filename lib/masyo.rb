# -*- coding: utf-8 -*-

require 'logger'
require 'forwardable'

require 'masyo/version'
require 'masyo/proxy'
require 'extentions/tcp_socket'

module Masyo
  extend self

  def run(opts = {})
    Thread.abort_on_exception = true
    Proxy.run(opts[:listen_port], opts[:server_host], opts[:server_port])
  end

  def logger
    @logger ||= Logger.new STDOUT
  end
end
