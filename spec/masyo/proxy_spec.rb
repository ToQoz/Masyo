# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo::Proxy do
  describe 'request' do
    context 'when fail to connect to server' do
      before do
        ::TCPSocket.stub(:open).and_raise(Errno::ECONNREFUSED)
        ::TCPServer.stub(:new)
      end

      let(:generate_proxy) do
        proc { described_class.new(7777, "0.0.0.0", 7779) }
      end

      it 'log error' do
        Masyo.logger.should_receive(:error).with("Fail to request to server")
        generate_proxy.call.request('msg')
      end
      it 'return nil' do
        expect(generate_proxy.call.request('msg')).to eq(nil)
      end
    end
  end
end
