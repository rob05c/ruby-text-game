class Player
  attr_reader :id
  attr_reader :name
  attr_accessor :room
  attr_accessor :health
  attr_accessor :mana
  attr_accessor :prompt_char
  attr_accessor :carrying

  # send_queue is a list[string].
  #
  # It's a queue of messages to send the player.
  #
  # This gives us a lot of flexibility and makes coordination easier
  # for events triggered by the player action, and
  # unrelated events that happen concurrent to player actions,
  #
  # Whenever something happens, it's added to the queue. If the player is mid-action,
  # all messages in the queue are sent in-order followed by the prompt.
  #
  # If the player isn't mid-action, i.e. is waiting at a prompt, messages are
  # queued and the queue is flushed and sent immediately after.
  #
  # This way, events triggered before a player's action ("the rabbit eyes you suspiciously"), direct results of the action ("you pick up a rabbit"),
  # unrelated concurrent events ("a deer walks in from the west"), and events triggered by/after the action ("the rabbit squirms uncomfortably")
  # are all sent to the player in the right order, with only 1 prompt at the end.
  #
  attr_accessor :send_queue

  # player_processing is a bool.
  #
  # Whether the player has sent a command, and we're in the middle of processing it.
  # This is ONLY used to indicate whether to send immediately to the player,
  # or wait and let the player's processing handle flushing the queue when it's done,
  # so that only 1 prompt is sent.
  #
  # This is NOT used to lock any action or event. The ONLY thing this blocks/prevents
  # is flushing the send queue to the player,
  # and thus whether the player receives 1 prompt at the end of processing, or a message+prompt when they're already sitting at a prompt.
  #
  # Of course, this will have to be locked carefully for multithreading
  #
  attr_accessor :processing
  alias processing? processing

  def initialize(id, name, room)
    @carrying = []
    @id = id
    @room = room
    @health = 100
    @mana = 100
    @carrying = [] # TODO: container sub/multi class?
    @wielding = []
    @prompt_char = '>' # TODO: make configurable?

    @send_queue = []
    @processing = false
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
    unless is_carrying
      send("You aren't carrying that.")
      return
    end

    @carrying.delete(obj)
    @room.add_item(obj)

    send("You drop #{obj.brief_desc} on the ground.")
  end

  def get(world, obj)
    found = false

    @room.items.each do |robj|
      if robj.id == obj.id
        found = true
        break
      end
    end

    unless found
      send("That isn't here.")
      return
    end

    unless obj.on_before_get.nil?
      disallow_msg = obj.on_before_get.call(world, self, obj)
      if disallow_msg != ''
        send(disallow_msg)
        return
      end
    end

    @carrying.push(obj)
    @room.items.delete(obj)
    send("You pick up #{obj.brief_desc}.")
    obj.on_after_get&.call(world, self, obj)
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

  # Sends msg to the player.
  #
  # Right now, this just prints. But we want to be able to easily find + replace
  # all user prints in the future, e.g. to support multiple users, telnet, ssh, etc.
  #
  # Does not automatically send a newline, to allow for prompts. Most calls besides prompts should send a newline
  def send(msg)
    msg += "\n" unless msg.end_with?("\n")

    # TODO: lock, if made parallel
    if !processing?
      send_queue([msg])
    else
      @send_queue.append(msg)
    end
  end

  # end_processing_and_send should only be called by the REPL when the player is at the end of the
  def end_processing_and_send
    # TODO: mutex/lock, if made parallel
    queue = @send_queue
    @send_queue = []
    @processing = false

    # TODO: I think we need 2 locks here, when parallel:
    #      a lock when swapping the queue above,
    #      but also a "send lock" over the entire method,
    #      to prevent another thread from coming in right here, and doing a send before us.
    #      It's fine at this point for another thread to add to the queue, it'll just result in the player getting another prompt.
    #      But it's not fine if they send a message to the player out-of-order

    do_send_queue(queue)
  end

  # send_queue sends the queue to the player, line-by-line, followed by a prompt.
  def do_send_queue(queue)
    # real_send("\n") if queue.length > 0

    queue.each do |msg|
      real_send(msg)
    end
    send_prompt
  end

  # real_send actually sends msg to the player. This should only be used by send and end_processing, never called directly
  def real_send(msg)
    print msg
  end

  # send_prompt sends the prompt to the player.
  # This should generally only be called by send_queue, or if the player hit enter without sending text.
  def send_prompt
    print prompt
  end
end
