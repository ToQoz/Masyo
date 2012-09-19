module Masyo
  class Server
    attr_accessor :tcp_server

    def self.open(*args)
      port = args.first
      raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)" if args.size <= 0
      raise ArgumentError, "#{port} is not a Integer" unless port.is_a? Integer

      server = new(port)
      return server unless block_given?
      begin
        yield server
      ensure
        server.close
      end
    end

    def initialize(port)
      @tcp_server = TCPServer.new(port)
    end

    def post(msg)
      Masyo.logger.info msg

      Thread.start do
        TCPSocket.open(Masyo.target_host, Masyo.target_port) { |socket|
          Masyo.logger.info "Succeed TCPSocket.open. `#{Masyo.target_host}:#{Masyo.target_port}`"

          socket.puts msg
          socket.close
        } rescue Masyo.logger.error "Failed TCPSocket.open. `#{Masyo.target_host}:#{Masyo.target_port}`"
      end
    end

    def awake
      loop {
        client = client!
        client.fcntl(Fcntl::F_SETFL, client.fcntl(Fcntl::F_GETFL) | Fcntl::O_NONBLOCK)

        handle_client client
      }
    end

    def handle_client(client)
      Thread.fork(client) do |c|
        loop {
          begin
            input = client.recv_nonblock(1000)
          rescue IO::WaitReadable
            if IO.select([ client ], nil, nil, 10)
              retry
            else
              # timeout!
              break
            end
          rescue
            input = ""
          else
            break if input == "" || input == "quit"

            trigger_event :on_read, input
          end
        }
        client.close
      end
    end

    ##
    # events
    ##
    def events
      @events ||= {}
    end

    def trigger_event(event_name, *arg)
      if events[event_name]
        events[event_name].each do |f|
          f.call *arg
        end
      end
    end

    def on_read(&handler)
      events[:on_read] ||= []
      events[:on_read] << handler
    end

    ##
    # delegate to TCPServer instance
    ##
    def client!
      tcp_server.accept
    end

    def close
      tcp_server.close
    end
  end
end
