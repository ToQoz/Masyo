# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo::Buffer do
  describe '#initialize' do
    context 'when given a number for args' do
      it 'should set it tomax length' do
        instance = Masyo::Buffer.new 100
        instance.maxlen.should eq(100)
      end
    end
    context 'when given none for args' do
      it 'should set 0 to max length' do
        instance = Masyo::Buffer.new
        instance.maxlen.should eq(0)
      end
    end
  end

  describe '#clear!' do
    it 'should clear buffer' do
      instance = Masyo::Buffer.new 100
      instance.buffer = "toqoz.should be_cool."
      instance.clear!
      instance.buffer.should eq("")

    end
  end

  describe '#take!' do
    it 'should return buffer and clear buffer' do
      instance = Masyo::Buffer.new 100
      instance.buffer = "toqoz.should be_cool."
      instance.take!.should eq("toqoz.should be_cool.")
      instance.take!.should eq("")
    end
  end

  describe '#push' do
    context 'when given string `don\'t` over buffer' do
      it 'should add string as buffer' do
        instance = Masyo::Buffer.new 100
        str1 = Array.new(50, "a").join("")
        str2 = Array.new(50, "b").join("")
        instance.push str1
        instance.push str2
        instance.buffer.should eq("#{str1}#{str2}")
      end
    end
    context 'when given string over buffer' do
      it 'raise error' do
        instance = Masyo::Buffer.new 100
        proc {
          instance.push Array.new(101, "a").join("")
        }.should raise_error(Masyo::BufferOverflowException)
      end
    end
  end
end
