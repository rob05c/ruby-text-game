module RubyTextGame
  module Direction
    NORTH = 'north'.freeze
    SOUTH = 'south'.freeze
    EAST = 'east'.freeze
    WEST = 'west'.freeze
    NORTH_EAST = 'northeast'.freeze
    NORTH_WEST = 'northwest'.freeze
    SOUTH_EAST = 'southeast'.freeze
    SOUTH_WEST = 'southwest'.freeze

    def self.reverse_dir(dir)
      case dir
      when NORTH
        SOUTH
      when SOUTH
        NORTH
      when EAST
        WEST
      when WEST
        EAST
      when NORTH_EAST
        SOUTH_WEST
      when NORTH_WEST
        SOUTH_EAST
      when SOUTH_EAST
        NORTH_WEST
      when SOUTH_WEST
        NORTH_EAST
      end
    end

    def self.from_str(str)
      str = str.strip.downcase
      case str
      when 'n', 'north'
        NORTH
      when 's', 'south'
        SOUTH
      when 'e', 'east'
        EAST
      when 'w', 'west'
        WEST
      when 'ne', 'northeast', 'north-east'
        NORTH_EAST
      when 'nw', 'northwest', 'north-west'
        NORTH_WEST
      when 'se', 'southeast', 'south-east'
        SOUTH_EAST
      when 'sw', 'southwest', 'south-west'
        SOUTH_WEST
      end
    end
  end
end
