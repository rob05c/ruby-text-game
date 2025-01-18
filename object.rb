class Object
  attr_accessor :id
  attr_accessor :word
  attr_accessor :brief_desc
  attr_accessor :long_desc

  # cmd is a command called when the player interacts with the object via standard commands
  # e.g. push, pull, poke, etc.
  # It's a regular command func, i.e. it's passed the world, player, and args the player typed
  # If unset, it defaults to object_cmd_default, which gives the player rote inaction responses.
  attr_accessor :cmd

  def initialize(id, word, brief_desc, long_desc)
    @id = id
    @word = word
    @brief_desc = brief_desc
    @long_desc = long_desc
    @cmd = ->(world, player, args) { object_cmd_default(self, world, player, args) }
  end
end

def object_cmd_default(object, world, player, args)
  cmd = args[0]
  cmd = cmd.strip.downcase

  "You #{cmd} the #{@word}, but nothing seems to happen."
end

class Weapon < Object
  def initialize(id, word, brief_desc, long_desc, damage, attack_msg_tpl)
    @damage = damage
    @attack_msg_tpl = attack_msg_tpl
    super(id, word, brief_desc, long_desc)
  end

  def attack_msg(second_person, third_person)
    msg = @attack_msg_tpl + ' with ' + @brief_desc + '.'
    msg = format(msg, titleize(second_person), third_person)
    msg
  end
end

class Sword < Weapon
  def initialize(id, brief_desc, long_desc, damage)
    attack_msg_tpl = '%s slice into %s'
    word = 'sword'
    super(id, word, brief_desc, long_desc, damage, attack_msg_tpl)
  end
end

# TODO: put in util func?
def titleize(str)
  str.gsub(/\w+/) do |word|
    word.capitalize
  end
end

# creats a world key object, which lets the holder create rooms.
def make_world_key(world)
  obj = Object.new(world.new_id, 'key', 'an unobtrusive key', 'This unremarkable key seems to be made of iron.')
  obj.cmd = ->(world, player, args) { world_key_cmd(obj, world, player, args) }
  obj
end

def world_key_cmd(key, world, player, args)
  verb = args[0].strip.downcase

  player_is_carrying = player.carrying?(key)

  return 'The key shimmers slightly.' unless player_is_carrying

  return 'The key glistens.' if verb != 'turn'

  room_obj = make_room_obj(world)
  player.carrying.push(room_obj)

  'The key glows in your hands, and you suddenly find the end of the key inserted into an inexplicable fragment of reality which you now hold.'
end

# RoomItem is a room item, used to create new rooms via a world key.
class RoomItem < Object
  attr_accessor :room
  def initialize(id, world)
    @room = Room.new(world.new_id, '', '', '')
    word = 'fragment'
    brief_desc = 'a miniature fragment of reality'
    long_desc = 'A fractal section of the universe rests here calmly.'
    super(id, word, brief_desc, long_desc)
    @cmd = method(:room_obj_cmd)
  end

  def room_obj_cmd(world, player, args)
    verb = args[0].strip.downcase

    if verb == 'spin'
      return "The #{@word} spins in place, but the current location rejects it." if args.length < 3

      direction_str = args[2].strip.downcase
      direction = Direction.from_str(direction_str)

      if direction.nil?
        return "The #{@word} spins #{direction_str}, but the universe feels you aren't ready for that direction yet."
      end

      if (@room.title == '') || (@room.short_desc == '') || (@room.long_desc == '')
        return "The #{@word} spins briefly and falls over."
      end

      room = player.room
      existing_room = world.get_room_link(room, direction)
      return "The #{@word} spins to the #{direction_str}, but the existing fabric rejects it." unless existing_room.nil?

      world.rooms[room.id] = @room
      world.link_rooms(room, direction, @room)
      player.carrying.delete(self)

      return "The #{@word} spins into the fabric of the universe."

    end

    return "The #{@word} of reality bristles." if verb != 'push'

    return "The #{@word} of reality stares at you awkwardly." if args.length < 3

    desc = args.slice(2, args.length)
    desc = desc.join(' ').strip

    puts "DEBUG roc '#{@room.title}' '#{@room.short_desc}' '#{@room.long_desc}'"

    if @room.title == ''
      @room.title = desc
      "The #{@word} ripples takes on form."
    elsif @room.short_desc == ''
      @room.short_desc = desc
      "The #{@word} ripples takes on shape."
    elsif @room.long_desc == ''
      @room.long_desc = desc
      "The #{@word} ripples takes on meaning."
    else
      "The #{@word} shudders with potential."
    end
  end
end

def make_room_obj(world)
  RoomItem.new(world.new_id, world)
end
