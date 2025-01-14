#!/usr/bin/env -S ruby -w

require_relative 'world'
require_relative 'idgen'
require_relative 'object'
require_relative 'room'
require_relative 'command'
require_relative 'direction'

def repl(world, player)
  loop do
    send(player.prompt)
    input = read
    return false if repl_eval(world, player, input)
  end
end

def read
  txt = gets.chomp
  txt
end

# replEval handles user input. This is the 'eval' part of read-eval-print-loop.
#
# returns whether to stop the repl loop and quit the game.
def repl_eval(world, player, msg)
  # TODO: add sanitisation function
  msg = msg.strip

  # if the user just hit enter with no text (or only whitespace), just print a prompt
  return false if msg == ''

  # lmsg = msg.lower()
  lmsg = msg.tr('  ', ' ')
  args = lmsg.split(' ')

  if args.length == 0
    return false # just send another prompt
  end

  # TODO: integrate with command module?
  arg0 = args[0]
  if (arg0 == 'quit') || (arg0 == 'exit') || (arg0 == 'q')
    send("Goodbye!\n")
    return true
  end

  cmd = get_command(args)

  # TODO: pass parameter for writing to user? or make send a member of world?

  msg = cmd.call(world, player, args)

  send(msg + "\n")
  false
end

# Sends msg to the user.
#
# Right now, this just prints. But we want to be able to easily find + replace
# all user prints in the future, e.g. to support multiple users, telnet, ssh, etc.
#
# Does not automatically send a newline, to allow for prompts. Most calls besides prompts should send a newline
def send(msg)
  print msg
end

ii = IdGenerator.new

id = ii.get
puts "id: #{id}"

id = ii.get
puts "id: #{id}"

world = World.new

puts "wid: #{world.new_id}"
puts "wid: #{world.new_id}"
puts "wid: #{world.new_id}"

sword = Sword.new(42, 'a short sword', 'this sword is very short', 99)

attack_msg = sword.attack_msg('you', 'a scrawny goblin')

puts "sword: #{attack_msg}"

world = World.new

roomA = Room.new(world.new_id, 'A small garden', "This garden isn't very large.", 'The garden smells like wildflowers')
roomB = Room.new(world.new_id, 'A large kitchen', 'This kitchen is quite large. Pots hang on the walls, and something smells good.', 'The garden smells like wildflowers')

world.link_rooms(roomA, Direction::EAST, roomB)

# puts "room id #{room.id} title '#{room.title}'"

player = world.make_player('george', roomA)

sword = Sword.new(world.new_id, 'a short sword', 'This is a very shiny sword.', 42)
cup = Object.new(world.new_id, 'cup', 'an ornate silver cup', 'This cup is very ornate and silver.')

player.add_item(sword)
player.add_item(cup)

# msg = look(world, player, ['look'])
# puts "look: #{msg}"

repl(world, player)
