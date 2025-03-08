module RubyTextGame
  ##
  # Contains the entire game state.
  # After creation, you must call Start to start the event queue and acquire any other resources.
  # When finished with the world, Stop must be called to release resources.
  class World
    attr_accessor :rooms, :rand, :lock

    def initialize
      print("creating new world\n")
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

      print("creating new world EventQueue\n")
      @event_queue = EventQueue.new
    end

    def Start
      @event_queue.start # TODO: move to World.start ?
    end

    def Stop
      @event_queue.stop
    end

    def new_id
      @id_generator.get
    end

    def make_player(name, room)
      player = Player.new(@id_generator.get, name, room)
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
