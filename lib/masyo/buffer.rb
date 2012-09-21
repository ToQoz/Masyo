# -*- coding: utf-8 -*-

module Masyo
  class BufferOverflowException < StandardError; end

  class Buffer
    attr_accessor :maxlen

    def initialize(maxlen)
      @maxlen = maxlen
      @buffer = ""
    end

    def take!
      b = @buffer
      clear!
      b
    end

    def push(str)
      if @buffer.bytesize + str.bytesize < @maxlen
        @buffer += str
      else
        raise BufferOverflowException
      end
    end
    alias_method :<<, :push

    def clear!
      @buffer = ""
    end
  end
end
