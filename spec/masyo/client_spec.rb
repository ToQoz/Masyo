# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo::Client do
  describe '#initialize' do
    let(:buffered_client) {
      buffer = double(maxlen: 100)
      described_class.new("0.0.0.0", 8080, buffer)
    }
    let(:plain_client) {
      buffer = double(maxlen: 0)
      described_class.new("0.0.0.0", 8080, buffer)
    }

    context 'when buffer_size > 0' do
      it 'should use BufferedClient#post as #post' do
        buffered_client.method("post").owner.should eq(Masyo::BufferedClient)
      end
    end

    context 'when buffer_size == 0' do
      it 'should use PlainClient#post as #post' do
        plain_client.method("post").owner.should eq(Masyo::PlainClient)
      end
    end
  end
  
  describe '#post' do
    let (:instance) { described_class.new("0.0.0.0", 8212, double(maxlen: 10)) }
    it 'should call TCPSocket.open' do
      TCPSocket.should_receive(:open).with(kind_of(String), kind_of(Numeric))
      instance.post("dummy message")
    end
  end
end
