require_relative 'object'

class Room
  attr_reader :id
  attr_accessor :title
  attr_accessor :short_desc
  attr_accessor :long_desc
  attr_accessor :items

  def initialize(id, title, short_desc, long_desc)
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
end
