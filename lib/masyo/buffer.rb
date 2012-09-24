# -*- coding: utf-8 -*-

module Masyo
  class BufferOverflowException < StandardError; end

  class Buffer
    attr_accessor :maxlen, :buffer

    def initialize(maxlen = 0)
      @maxlen = maxlen
      @buffer = ""
    end

    def take!
      b = buffer
      clear!
      b
    end

    def push(str)
      if buffer.bytesize + str.bytesize <= maxlen
        self.buffer += str
      else
        raise BufferOverflowException
      end
    end
    alias_method :<<, :push

    def clear!
      self.buffer = ""
    end
  end
end
