# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo do
  describe "#run" do
    before :each do
      Masyo::Proxy.stub(:run)
    end

    it "should call Server.open with port" do
      Masyo::Proxy.should_receive(:run).with(7777, "0.0.0.0", 7779)
      described_class.run(listen_port: 7777, server_host: "0.0.0.0", server_port: 7779)
    end
  end

  describe "#logger" do
    it 'should return Logger instance.' do
      described_class.logger.is_a?(Logger).should be_true
    end
  end
end
