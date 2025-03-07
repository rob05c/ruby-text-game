module RubyTextGame
  # require_relative 'direction'
  # require 'test/unit'

  include Direction

  class TestDirection < Test::Unit::TestCase
    def test_reverse_dir
      input_expected = {
        Direction::NORTH => Direction::SOUTH,
        Direction::SOUTH => Direction::NORTH,
        Direction::EAST => Direction::WEST,
        Direction::WEST => Direction::EAST,
        Direction::NORTH_WEST => Direction::SOUTH_EAST,
        Direction::NORTH_EAST => Direction::SOUTH_WEST,
        Direction::SOUTH_WEST => Direction::NORTH_EAST,
        Direction::SOUTH_EAST => Direction::NORTH_WEST
      }
      input_expected.each do |input, expected|
        assert_equal(expected, Direction.reverse_dir(input))
        assert_equal(Direction.reverse_dir(Direction.reverse_dir(input)), input)
      end
    end

    def test_from_str
      input_expected = {
        'n' => Direction::NORTH,
        'north' => Direction::NORTH,
        'NORTH' => Direction::NORTH,
        'NorTH' => Direction::NORTH,
        's' => Direction::SOUTH,
        'south' => Direction::SOUTH,
        'SOUTH' => Direction::SOUTH,
        'e' => Direction::EAST,
        'east' => Direction::EAST,
        'EAST' => Direction::EAST,
        'NORTHeast' => Direction::NORTH_EAST,
        'sw' => Direction::SOUTH_WEST,
        'foo' => nil
      }
      input_expected.each do |input, expected|
        assert_equal(expected, Direction.from_str(input))
      end
    end
  end
end
