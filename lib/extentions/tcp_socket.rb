# -*- coding: utf-8 -*-

class TCPSocket
  def close_immediately
    setsockopt(::Socket::SOL_SOCKET, ::Socket::SO_LINGER, [1,0].pack('ii'))
    close
  end
end
