require_relative 'direction'

include Direction

# Returns the function for the command the player ran.

# If the player tried to do something that doesn't exist in their context,
# unknownCommand is returned.
def get_command(args)
  return method(:no_command) if args.length == 0

  base_cmds = base_commands # TODO: cache? make Commands an object?

  arg0 = args[0]
  arg0 = arg0.downcase
  arg0 = arg0.strip

  return base_cmds[arg0] if base_cmds.key?(arg0)

  # TODO: support player-specific commands, e.g. class, skills, etc

  method(:unknown_command)
end

def base_commands
  {
    'look' => method(:look),
    'l' => method(:look),
    'go' => method(:move),
    'move' => method(:move),
    'drop' => method(:drop),
    'get' => method(:get),
    'i' => method(:inventory),
    'inv' => method(:inventory),
    'inventory' => method(:inventory)
  }
end

def room_directions_str(world, room)
  # TODO: move to room member var?
  links = world.get_room_links(room)
  return "You don't see any way out." if links.length == 0

  exit_strs = []
  links.each do |direction, room|
    exit_strs.append(direction)
  end

  "You see exits leading #{exit_strs.join(', ')}."
end

def room_items_str(world, room)
  item_descs = []
  room.items.each do |item|
    # TODO: add ground desc to item
    item_str = "There is #{item.brief_desc} here."
    item_descs.append(item_str)
  end

  return "You don't see anything here." if item_descs.length == 0

  item_descs.join(' ')
end

def look(world, player, args)
  room = player.room
  ris = room_items_str(world, room)
  rds = room_directions_str(world, room)
  msg = "#{room.title}\n\n#{room.short_desc}\n#{ris}\n#{rds}"
  msg
end

def move(world, player, args)
  return 'Where do you want to go?' if args.length < 2

  direction_str = args[1]
  direction = Direction.from_str(direction_str)
  return 'You wiggle about.' if direction.nil?

  room = player.room

  new_room = world.get_room_link(room, direction)
  return 'The way is shut.' if new_room.nil?

  player.room = new_room

  # TODO: make auto-look-on-move configurable?
  msg = look(world, player, [])

  msg
end

def drop(world, player, args)
  return 'What do you want to drop?' if args.length < 2

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
  return "You aren't carrying a #{item_str}." if item.nil?

  player.drop(item)
end

def get(world, player, args)
  return 'What do you want to get?' if args.length < 2

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

  return "You don't see a #{item_str} here." if item.nil?

  player.get(item)
end

def inventory(world, player, args)
  item_strs = []
  player.carrying.each do |item|
    item_strs.push(item.brief_desc)
  end

  item_str = item_strs.join(', ')
  "You are carrying #{item_str}."
end

# no_command is used when the player sends just a return or whitespace.
# In which case, we don't send them anything, just another prompt.

# This is distinct from the player entering an unknown command.
def no_command(world, player, args)
  ''
end

def unknown_command(world, player, args)
  'What was that now?'
end
