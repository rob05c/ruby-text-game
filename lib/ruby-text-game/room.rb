module RubyTextGame
  # require_relative 'object'
  class Room
    attr_reader :id
    attr_accessor :title, :short_desc, :long_desc, :items

    def initialize(id, title, short_desc, long_desc)
      # TODO: change to set? iterating over a lot of items would be slow, but do we expect thousands of item?
      @items = []
      @id = id
      @title = title
      @short_desc = short_desc
      @long_desc = long_desc
      @items = []
    end

    ##
    # Low-level func to add an item directly.
    #
    # Returns no message, and has no checks or removal from anywhere else.
    def add_item(obj)
      @items.push(obj)
    end

    def has_item?(obj)
      @items.each do |room_item|
        return true if room_item == obj

        return false
      end
      false # false if the room had no items
    end

    # TODO: add room remove item, and events
  end
end
