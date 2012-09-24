# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo do
  describe 'Masyo#configure' do
    context 'when givin a hash' do
      context 'if Masyo have hash\'s key as accessor' do
        it 'should set it to instance variables.' do
          Masyo.configure(
            target_host: "toqoz.net",
            target_port: 1234,
            buffer_size: 100,
            port: 4321
          )

          Masyo.target_host.should eq("toqoz.net")
          Masyo.target_port.should eq(1234)
          Masyo.buffer_size.should eq(100)
          Masyo.port.should eq(4321)
        end
      end
      context 'if Masyo `don\'t` have hash\'s key as accessor' do
        it 'should `not` it to instance variables.' do
          Masyo.configure(invalid_accsossor: "toqoz.net")

          Masyo.respond_to?(:invalid_accsossor).should be_false
        end
      end
    end
  end
end
