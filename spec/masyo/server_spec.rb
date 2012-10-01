# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo::Server do
  let (:instance) { described_class.new(8183) }
  let (:logger) { double(info: true, error: true) }

  after(:each) do
    instance.close
  end

  describe '.open' do
    context 'when given over 2 args' do
      it 'should recieve ArgumentError' do
        proc { described_class.open(8183, "hoge", "foo") }.should raise_error(ArgumentError)
      end
    end
    context 'when given non-number value as first arg' do
      it 'should recieve ArgumentError' do
        proc { described_class.open("9090") }.should raise_error(ArgumentError)
      end
    end
  end

  describe '#initialize' do
    it 'store ::TCPServer as instance variable' do
      instance.tcp_server.is_a?(::TCPServer).should be_true
    end
  end

  describe '#handle_request' do
    let (:socket) { double(close_immediately: nil, closed?: false) }

    context 'when BasicSocket#recv_nonblock raise IO::WaitReadable' do
      before :each do
        socket.stub(:recv_nonblock).and_raise(StandardError.new.extend(IO::WaitReadable))
      end

      it 'should call IO.select.' do
        IO.should_receive(:select).
          with([ socket ], nil, nil, described_class::TO_CLIENT_SOCKET_TIMEOUT).
          and_return(false)
        instance.handle_request(socket)
      end
    end

    context "when BasicSocket#recv_nonblock don't raise IO::WaitReadable" do
      let (:input) { "dummy_input" }

      before :each do
        socket.stub(:recv_nonblock).and_return(input, "")
      end

      context 'and when input is not false, nil, "", "quit"' do
        it 'should call trigger_event with :read as first arg, and input as second arg' do
          instance.should_receive(:trigger_event).with(:read, input)
          proc {
            instance.handle_request(socket)
          }.should_not raise_error
        end
      end
    end

    context 'when raise Exception except IO::WaitReadable' do
      it 'should close socket and not catch Exceptions.' do
        socket.stub(:recv_nonblock).and_raise(StandardError)
        socket.should_receive(:close_immediately)

        proc {
          instance.handle_request(socket)
        }.should raise_error(StandardError)
      end
    end
  end
end

describe ::TCPServer do
  describe '#close_immediately' do
    it 'should receive setsockopt with relavant options and close' do
      socket = described_class.new(8183)
      socket.should_receive(:setsockopt).with(Socket::SOL_SOCKET, Socket::SO_LINGER, [1,0].pack('ii'))
      socket.should_receive(:close)
      socket.close_immediately
    end
  end
end
