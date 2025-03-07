module RubyTextGame
  # require_relative 'object'
  # require_relative 'world'
  class NPC < GameObject
    def initialize(id, word, brief_desc, long_desc, meander)
      @meander_interval_s = 5 # TODO: make configurable
      @on_after_move = method(:after_move) if meander

      super(id, word, brief_desc, long_desc)
    end

    def after_move(world, location, object)
      # puts "DEBUG after_move #{id} #{word}"
      return unless location.is_a?(Room)

      world.add_event(Time.now + @meander_interval_s, lambda {
        meander(world, location)
      })
    end

    ## meander should only be called by after_move
    def meander(world, location)
      return unless location.is_a?(Room) # shouldn't be possible. TODO log error?

      old_room = location

      # TODO: fix. This is a terrible hack, and terribly slow. Need to refactor locations
      #       Also, after_move shouldn't take a location, it should look up the object's location.
      unless old_room.has_item?(self)
        # if the object has moved, e.g. someone picked it up, don't meander
        return
      end

      links = world.get_room_links(old_room)

      return if links.length == 0 # nowhere to meander

      dir_n = world.rand.rand(links.length)

      dir = links.keys[dir_n]
      new_room = links[dir]

      old_room = location
      old_room.items.delete(self)
      new_room.add_item(self)

      # TODO: make npc exit+enter msg configurable
      exit_msg = "#{brief_desc} ambles out to the #{dir}"
      entrance_msg = "#{brief_desc} ambles in from the #{Direction.reverse_dir(dir)}"

      world.send_room_msg(old_room, exit_msg)
      world.send_room_msg(new_room, entrance_msg)

      world.add_event(Time.now + @meander_interval_s, -> { meander(world, new_room) })
    end
  end
end
