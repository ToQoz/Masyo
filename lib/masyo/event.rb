# -*- coding: utf-8 -*-

module Masyo
  module Event

    def self.included(base)
      base.event_types.each do |e|
        base.class_eval {
          define_method("on_#{e}") do |&handler|
            events[e] ||= []
            events[e] << handler
          end
        }
      end
    end

    def events
      @events ||= {}
    end

    def trigger_event(name, *arg)
      if events[name]
        events[name].each do |f|
          f.call *arg
        end
      end
    end
  end
end
