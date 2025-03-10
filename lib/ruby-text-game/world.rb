module RubyTextGame
  ##
  # Contains the entire game state.
  # After creation, you must call start to start the event queue and acquire any other resources.
  # When finished with the world, stop must be called to release resources.
  #
  # Logging defaults to Rails.logger if it exists, else STDOUT at debug level.
  # To change, change the exposed @logger. E.g. `myWorld.logger.level = Logger::ERROR`.
  class World
    attr_accessor :rooms, :rand, :lock, :logger

    def initialize
      @logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)

      # Note nothing should be logged within initialize.
      # This is because users may want to immediately change the logger.
      #
      # If something needs to be logged here, we should either move it to start,
      # or change initialize to take the logger as an argument.

      @id_generator = IdGenerator.new
      @players = {}
      @rooms = {}
      @room_links = {}
      @objects = {}
      @rand = Random.new # TODO: add seed arg?
      @lock = Mutex.new

      # TODO: make object containers
      # { object : room|player }
      @objects_locations = {}
      # { room : object }
      @room_objects = {}
      # { player : []object }
      @player_objects = {}

      @player_name_id = {} # player[name]id

      @event_queue = EventQueue.new
    end

    ##
    # Acts like File.open: creates a new World with the given args,
    # calls World.start, yields to a block, then calls World.stop.
    def self.run(*args)
      world = new(*args)
      world.start
      yield world
      world.stop
    end

    def start
      logger.info 'World.start'
      @event_queue.start
    end

    def stop
      logger.info 'World.stop'
      @event_queue.stop
    end

    def new_id
      @id_generator.get
    end

    def make_player(name, room)
      player = Player.new(@id_generator.get, self, name, room)
      @players[player.id] = player
      @player_name_id[name] = player.id
      player
    end

    def get_player_by_id(id)
      @players[id]
    end

    def get_player_by_name(name)
      id = @player_name_id[name]
      return nil if id.nil?

      @players[id]
    end

    def make_room(title, short_desc, long_desc)
      room = Room.new(@id_generator.get, title, short_desc, long_desc)
      @rooms[room.id] = room
      room
    end

    def link_rooms(roomA, direction, roomB)
      link_rooms_single(roomA, direction, roomB)
      link_rooms_single(roomB, RubyTextGame::Direction.reverse_dir(direction), roomA)
    end

    # Links roomA to roomB via direction.
    # This should only be used for special non-bidirectional paths. Use linkRooms for normal bidirectional paths.
    def link_rooms_single(roomA, direction, roomB)
      # TODO: error if link exists?
      @room_links[roomA] = {} unless @room_links.key?(roomA)
      @room_links[roomA][direction] = roomB
    end

    def get_room_links(room)
      return {} unless @room_links.key?(room)

      @room_links[room]
    end

    def get_room_link(room, direction)
      return nil unless @room_links.key?(room) # TODO: invalid direction enum?

      links = @room_links[room]
      return nil unless links.key?(direction)

      links[direction]
    end

    def add_event(time, fn)
      world_locked_fn = lambda {
        @lock.synchronize do
          fn.call
        end
      }
      @event_queue.add_event(time, world_locked_fn)
    end

    # TODO: move to Room? Give room access to links? players?
    def send_room_msg(room, msg)
      # TODO: create player_rooms and room_players in World, this is crazy inefficient to check every player for every room msg
      @players.each do |id, player|
        next if player.room != room

        player.send(msg)
      end
    end
  end
end
