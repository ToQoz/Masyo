# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo::Buffer do
  let (:instance) { described_class.new 100 }

  describe '#initialize' do
    context 'when given a number for args' do
      it 'should set it tomax length' do
        described_class.new(100).maxlen.should eq(100)
      end
    end
    context 'when given none for args' do
      it 'should set 0 to max length' do
        described_class.new.maxlen.should eq(0)
      end
    end
  end

  describe '#clear!' do
    it 'should clear buffer' do
      instance.buffer = "toqoz.should be_cool."
      instance.clear!
      instance.buffer.should eq("")

    end
  end

  describe '#take!' do
    it 'should return buffer and clear buffer' do
      instance.buffer = "toqoz.should be_cool."
      instance.take!.should eq("toqoz.should be_cool.")
      instance.buffer.should eq("")
    end
  end

  describe '#push' do
    context 'when given string `don\'t` over buffer' do
      it 'should add string as buffer' do
        str = Array.new(100, "a").join("")
        instance.push str
        instance.buffer.should eq(str)
      end
    end
    context 'when given string over buffer' do
      it 'raise error' do
        proc {
          instance.push Array.new(101, "a").join("")
        }.should raise_error(Masyo::BufferOverflowException)
      end
    end
  end
end
