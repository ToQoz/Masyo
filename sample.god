#!/usr/bin/env ruby

God.watch do |w|
  root = File.expand_path("../", __FILE__)

  w.name = "Masyo"
  w.start = "bundle exec ruby #{File.join(root, 'bin', 'masyo')} --listen_port 2001 --server_host 0.0.0.0 --server_port 24224"
  w.interval = 180.second
  w.keepalive

  w.start_if do |start|
    start.condition(:process_running) do |c|
      c.running = false
    end
  end
end
