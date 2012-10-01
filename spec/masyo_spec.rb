# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo do
  describe "#run" do
    before :each do
      Masyo::Buffer.stub(:new)
      Masyo::Client.stub(:new)
      Masyo::Server.stub(:open)
    end

    it "should set Thread.abort_on_exception = true" do
      Thread.should_receive(:abort_on_exception=).with(true)
      described_class.run
    end

    it "should call Server.open with port" do
      Masyo::Server.should_receive(:open).with(kind_of(Numeric))
      described_class.run
    end
  end

  describe "#logger" do
    it 'should return Logger instance.' do
      described_class.logger.is_a?(Logger).should be_true
    end
  end
end
