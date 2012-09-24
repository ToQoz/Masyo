# -*- coding: utf-8 -*-

require 'spec_helper'

describe Masyo::Event do
  let(:instance) do
    mod = described_class
    Class.new {
      class << self
        def event_types
          [ :xxx ]
        end
      end

      include mod
    }.new
  end

  describe '.included' do
    context 'when included' do
      it 'define methods for event_types(return by base class methods)' do
        instance.respond_to?(:on_xxx).should be_true
      end
    end
  end

  describe '#on_*' do
    describe '#on_xxx' do
      it 'should store given block as event callback' do
        callback = proc {}
        instance.on_xxx(&callback)
        instance.events.should eq({ xxx: [ callback ] })
      end
    end
    context '#on_invalid_event' do
      it 'should `not` store given block as event callback' do
        proc {
          callback = proc {}
          instance.on_invalid_event(&callback)
        }.should raise_error(NoMethodError)

        instance.events.should eq({})
      end
    end
  end

  describe '#trigger_event' do
    context 'when given exist event anme' do
      it 'should trigger all event for #{name}(first args)' do
        callback = proc {}
        callback.should_receive(:call)
        instance.on_xxx(&callback)
        instance.trigger_event :xxx
      end
    end
    context 'when given `not` exist event anme' do
      it 'should not trigger all event for #{name}(first args)' do
        callback = proc {}
        callback.should_not_receive(:call)
        instance.on_invalid_event(&callback) rescue
        instance.trigger_event :invalid_event
      end
    end
  end
end
