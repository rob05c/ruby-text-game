module RubyTextGame
  include Direction

  # Returns the function for the command the player ran.

  # If the player tried to do something that doesn't exist in their context,
  # unknownCommand is returned.
  def self.get_command(args)
    return method(:no_command) if args.length == 0

    base_cmds = base_commands # TODO: cache? make Commands an object?

    arg0 = args[0]
    arg0 = arg0.downcase
    arg0 = arg0.strip

    return base_cmds[arg0] if base_cmds.key?(arg0)

    # TODO: support player-specific commands, e.g. class, skills, etc

    method(:unknown_command)
  end

  def self.base_commands
    {
      'look' => method(:look),
      'l' => method(:look),
      'go' => method(:move),
      'move' => method(:move),

      'd' => method(:drop),
      'drop' => method(:drop),
      'g' => method(:get),
      'get' => method(:get),

      'i' => method(:inventory),
      'inv' => method(:inventory),
      'inventory' => method(:inventory),

      'w' => ->(world, player, args) { go(world, player, Direction::WEST) },
      'west' => ->(world, player, args) { go(world, player, Direction::WEST) },
      'e' => ->(world, player, args) { go(world, player, Direction::EAST) },
      'east' => ->(world, player, args) { go(world, player, Direction::EAST) },
      'n' => ->(world, player, args) { go(world, player, Direction::NORTH) },
      'north' => ->(world, player, args) { go(world, player, Direction::NORTH) },
      's' => ->(world, player, args) { go(world, player, Direction::SOUTH) },
      'south' => ->(world, player, args) { go(world, player, Direction::SOUTH) },
      'ne' => ->(world, player, args) { go(world, player, Direction::NORTH_EAST) },
      'northeast' => ->(world, player, args) { go(world, player, Direction::NORTH_EAST) },
      'nw' => ->(world, player, args) { go(world, player, Direction::NORTH_WEST) },
      'northwest' => ->(world, player, args) { go(world, player, Direction::NORTH_WEST) },
      'sw' => ->(world, player, args) { go(world, player, Direction::SOUTH_WEST) },
      'southwest' => ->(world, player, args) { go(world, player, Direction::SOUTH_WEST) },
      'se' => ->(world, player, args) { go(world, player, Direction::SOUTH_WEST) },
      'southeast' => ->(world, player, args) { go(world, player, Direction::SOUTH_EAST) },

      'poke' => method(:interaction),
      'push' => method(:interaction),
      'pull' => method(:interaction),
      'turn' => method(:interaction),
      'spin' => method(:interaction)

    }
  end

  def self.room_directions_str(world, room)
    # TODO: move to room member var?
    links = world.get_room_links(room)
    return "You don't see any way out." if links.length == 0

    exit_strs = []
    links.each do |direction, room|
      exit_strs.append(direction)
    end

    "You see exits leading #{exit_strs.join(', ')}."
  end

  def self.room_items_str(world, room)
    item_descs = []
    room.items.each do |item|
      # TODO: add ground desc to item
      item_str = "There is #{item.brief_desc} here."
      item_descs.append(item_str)
    end

    return "You don't see anything here." if item_descs.length == 0

    item_descs.join(' ')
  end

  def self.look(world, player, args)
    room = player.room
    ris = room_items_str(world, room)
    rds = room_directions_str(world, room)
    player.send("#{room.title}\n\n#{room.short_desc}\n#{ris}\n#{rds}")
  end

  def self.move(world, player, args)
    if args.length < 2
      player.send('Where do you want to go?')
      return
    end

    direction_str = args[1]
    direction = Direction.from_str(direction_str)
    if direction.nil?
      player.send('You wiggle about.')
      return
    end

    go(world, player, direction)
  end

  # go moves player in dir.
  # This is a utility func, not a command, i.e. it doesn't conform to func(world,player,args).
  def self.go(world, player, direction)
    room = player.room

    new_room = world.get_room_link(room, direction)
    if new_room.nil?
      player.send('The way is shut.')
      return
    end

    player.room = new_room

    # TODO: make auto-look-on-move configurable?
    look(world, player, [])
  end

  def self.drop(world, player, args)
    if args.length < 2
      player.send('What do you want to drop?')
      return
    end

    item_str = args[1]
    item_str = item_str.strip.downcase
    # TODO: deduplicate get logic and message with player.drop
    item = nil
    player.carrying.each do |player_item|
      next unless player_item.word == item_str

      # TODO: disambiguate multiple items with the same word?
      item = player_item
      break
    end

    if item.nil?
      player.send("You aren't carrying a #{item_str}.")
      return
    end

    player.drop(world, item)
  end

  def self.get(world, player, args)
    if args.length < 2
      player.send('What do you want to get?')
      return
    end

    item_str = args[1]
    item_str = item_str.strip.downcase
    # TODO: deduplicate get logic and message with player.drop
    item = nil
    player.room.items.each do |room_item|
      next unless room_item.word == item_str

      # TODO: disambiguate multiple items with the same word?
      item = room_item
      break
    end

    if item.nil?
      player.send("You don't see a #{item_str} here.")
      return
    end

    player.get(world, item)
  end

  def self.inventory(world, player, args)
    item_strs = []
    player.carrying.each do |item|
      item_strs.push(item.brief_desc)
    end

    item_str = item_strs.join(', ')
    player.send("You are carrying #{item_str}.")
  end

  # no_command is used when the player sends just a return or whitespace.
  # In which case, we don't send them anything, just another prompt.

  # This is distinct from the player entering an unknown command.
  def self.no_command(world, player, args)
    nil
  end

  def self.unknown_command(world, player, args)
    player.send('What was that now?')
  end

  # interaction is a generic command for interaction commands with objects:
  # push, pull, poke, etc.
  # It searches the player's inventory, then the room, for items with the given word.
  def self.interaction(world, player, args)
    verb = args[0].strip.downcase
    if args.length < 2
      player.send("What do you want to #{verb}?")
      return
    end

    noun = args[1]
    obj = nil
    # TODO: put in a "get_player_obj(word)" func
    player.carrying.each do |pobj|
      if pobj.word == noun
        obj = pobj
        break
      end
    end

    if obj.nil?
      player.room.items.each do |robj|
        if robj.word == noun
          obj = robj
          break
        end
      end
    end

    if obj.nil?
      player.send("You don't see a #{noun} to #{verb}.")
      return
    end

    obj.cmd.call(world, player, args)
  end
end
