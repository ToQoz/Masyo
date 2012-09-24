# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo::Server do
  describe '.open' do
    context 'when given over 2 args' do
      it 'should recieve ArgumentError' do
        proc { Masyo::Server.open(8183, "hoge", "foo") }.should raise_error(ArgumentError)
      end
    end
    context 'when given non-number value as first arg' do
      it 'should recieve ArgumentError' do
        proc { Masyo::Server.open("9090") }.should raise_error(ArgumentError)
      end
    end
  end

  describe '#initialize' do
    it 'store ::TCPServer as instance variable' do
      instance = Masyo::Server.new(8183)
      instance.tcp_server.is_a?(::TCPServer).should be_true
      instance.close
    end
  end

  describe '#handle_client' do
    before(:all) do
      Masyo.stub(:buffer_size).and_return(100)
    end
    after(:all) do
      instance.close
    end

    let (:socket) { double(close: true, closed?: false, setsockopt: true ) }
    let (:instance) { Masyo::Server.new(8183) }

    context 'when raise IO::WaitReadable' do
      context 'when before timeout' do
        it 'should call IO.select.' do
          socket.stub(:recv_nonblock).and_raise(StandardError.new.extend(IO::WaitReadable))
          IO.should_receive(:select).with([ socket ], nil, nil, Masyo::Server::CLIENT_SOCKET_TIMEOUT).and_return(false)
          instance.handle_socket(socket)
        end
      end
    end

    context 'when raise Ecxeption except IO::WaitReadable' do
      it 'should close socket.' do
        socket.stub(:recv_nonblock).and_raise(StandardError)
        socket.should_receive(:setsockopt).with(Socket::SOL_SOCKET, Socket::SO_LINGER, [1,0].pack('ii'))
        socket.should_receive(:close)

        begin
          instance.handle_socket(socket)
        rescue
        end
      end
    end
  end

  describe '#post' do
    let (:instance) { Masyo::Server.new(8183) }
    let (:logger) { double(info: true, error: true) }

    before(:each) do
      Masyo.stub(:target_port).and_return(1234)
      Masyo.stub(:target_host).and_return("0.0.0.0")
      Masyo.stub(:logger).and_return(logger)
    end

    after(:each) do
      instance.close
    end

    it 'should call Logger#info. with given msg.' do
      msg = "posted message"

      logger.should_receive(:info).once.with(msg)
      instance.post msg
    end

    context 'when fail' do
      it 'should call Logger#error' do
        TCPSocket.stub(:open).and_raise
        msg = "posted message"

        logger.should_receive(:error).once
        instance.post msg
      end
    end

    context 'when success' do
      it 'should call Logger#info with target server info' do
        socket = double(TCPSocket, puts: true)
        TCPSocket.stub(:open) { |&block| block.yield socket }
        msg = "posted message"

        logger.should_receive(:info).twice
        instance.post msg
      end
    end
  end
end
