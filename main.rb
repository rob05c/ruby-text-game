#!/usr/bin/env -S ruby -w

require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  # gem 'ruby-text-game', git: 'https://github.com/rob05c/ruby-text-game.git', tag: 'v0.0.4'
  gem 'ruby-text-game', path: '.'
end

require 'ruby-text-game'

def repl(world, player)
  player.send_prompt # send initial prompt
  loop do
    input = read
    return false if repl_eval(world, player, input)
  end
end

def read
  gets.chomp
end

# replEval handles user input. This is the 'eval' part of read-eval-print-loop.
#
# returns whether to stop the repl loop and quit the game.
def repl_eval(world, player, msg)
  player.processing = true

  # TODO: add sanitisation function
  msg = msg.strip

  # if the user just hit enter with no text (or only whitespace), just print a prompt
  if msg == ''
    player.send('')
    return false
  end

  # lmsg = msg.lower()
  lmsg = msg.tr('  ', ' ')
  args = lmsg.split(' ')

  if args.length == 0
    player.send('')
    return false # just send another prompt
  end

  # TODO: integrate with command module?
  arg0 = args[0]
  if (arg0 == 'quit') || (arg0 == 'exit') || (arg0 == 'q')
    player.send("Goodbye!\n")
    return true
  end

  cmd = RubyTextGame.get_command(args)

  # TODO: pass parameter for writing to user? or make send a member of world?

  world.lock.synchronize do
    cmd.call(world, player, args)
  end
  false
ensure
  player.end_processing_and_send
end

ii = RubyTextGame::IdGenerator.new

id = ii.get
puts "id: #{id}"

id = ii.get
puts "id: #{id}"

puts 'Running world.'
RubyTextGame::World.run do |world|
  puts "wid: #{world.new_id}"
  puts "wid: #{world.new_id}"
  puts "wid: #{world.new_id}"

  sword = RubyTextGame::Sword.new(42, 'a short sword', 'this sword is very short', 99)

  attack_msg = sword.attack_msg('you', 'a scrawny goblin')

  puts "sword: #{attack_msg}"
end
puts 'Ran world.'

world = RubyTextGame::World.new
world.start

roomA = RubyTextGame::Room.new(world.new_id, 'A small garden', "This garden isn't very large.",
                               'The garden smells like wildflowers')
roomB = RubyTextGame::Room.new(world.new_id, 'A large kitchen',
                               'This kitchen is quite large. Pots hang on the walls, and something smells good.', 'The garden smells like wildflowers')

world.link_rooms(roomA, RubyTextGame::Direction::EAST, roomB)

# puts "room id #{room.id} title '#{room.title}'"

player = world.make_player('george', roomA)
player.send_fn = lambda { |msg|
  print msg
}

sword = RubyTextGame::Sword.new(world.new_id, 'a short sword', 'This is a very shiny sword.', 42)
cup = RubyTextGame::GameObject.new(world.new_id, 'cup', 'an ornate silver cup', 'This cup is very ornate and silver.')

player.add_item(sword)
player.add_item(cup)

world_key = RubyTextGame.make_world_key(world)
player.add_item(world_key)

goblin = RubyTextGame::NPC.new(world.new_id, 'goblin', 'a pungent goblin', 'This goblin is quite rank.', true)
player.add_item(goblin)

# msg = look(world, player, ['look'])
# puts "look: #{msg}"

# eq = EventQueue.new
# eq.start

# debug
# world.add_event(Time.now + 5, -> { puts 'event-05' })
# world.add_event(Time.now + 10, -> { puts 'event-10' })
# world.add_event(Time.now + 7, -> { puts 'event-07' })
# world.add_event(Time.now + 2, -> { puts 'event-02' })
# world.add_event(Time.now + 2, -> { puts 'event-01' })

repl(world, player)
