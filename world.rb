require_relative 'idgen'
require_relative 'player'

class World
  def initialize
    print("creating new world\n")
    @id_generator = IdGenerator.new
    @players = {}
    @rooms = {}
    @room_links = {}
    @objects = {}
  end

  def new_id
    @id_generator.get
  end

  def make_player(name, room)
    player = Player.new(@id_generator.get, name, room)
    @players[player.id] = player
    player
  end

  def make_room(title, short_desc, long_desc)
    room = Room.new(@id_generator.get, title, short_desc, long_desc)
    @rooms[room.id] = room
    room
  end

  def link_rooms(roomA, direction, roomB)
    link_rooms_single(roomA, direction, roomB)
    link_rooms_single(roomB, Direction.reverse_dir(direction), roomA)
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
end
