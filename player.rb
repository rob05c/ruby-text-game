class Player
  attr_reader :id
  attr_reader :name
  attr_accessor :room
  attr_accessor :health
  attr_accessor :mana
  attr_accessor :prompt_char
  attr_accessor :carrying

  def initialize(id, name, room)
    @carrying = []
    @id = id
    @room = room
    @health = 100
    @mana = 100
    @carrying = [] # TODO: container sub/multi class?
    @wielding = []
    @prompt_char = '>' # TODO: make configurable?
  end

  def prompt
    "#{@health}h #{@mana}m #{@prompt_char} "
  end

  def wield(obj)
    is_carrying = false
    @carrying.each do |cobj|
      if obj.id == cobj.id
        is_carrying = true
        break
      end
    end
    return "You aren't carrying that." unless is_carrying

    @carrying.delete(obj)
    @wielding.push(obj)
    "You wield #{obj.brief_desc}."
  end

  def unwield(obj)
    is_wielding = false

    @wielding.each do |wobj|
      if wobj.id == obj.id
        is_wielding = true
        break
      end
    end

    return "You aren't wielding that." unless is_wielding

    @wielding.delete(obj)
    @carrying.push(obj)
    "You put #{obj.brief_desc} away."
  end

  def drop(obj)
    # TODO: de-duplicate with wield
    is_carrying = false
    @carrying.each do |cobj|
      if cobj.id == obj.id
        is_carrying = true
        break
      end
    end
    return "You aren't carrying that." unless is_carrying

    @carrying.delete(obj)
    @room.add_item(obj)

    "You drop #{obj.brief_desc} on the ground."
  end

  def get(obj)
    found = false

    @room.items.each do |robj|
      if robj.id == obj.id
        found = true
        break
      end
    end

    return "That isn't here." unless found

    @carrying.push(obj)
    @room.items.delete(obj)
    "You pick up #{obj.brief_desc}."
  end

  def carrying?(obj)
    # TODO: de-duplicate with drop etc?
    @carrying.each do |cobj|
      return true if cobj.id == obj.id
    end
    false
  end

  ##
  # Low-level func to add an item directly.
  # Returns no message, and has no checks or removal from anywhere else.
  def add_item(obj)
    @carrying.push(obj)
  end
end
