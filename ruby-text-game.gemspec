Gem::Specification.new do |spec|
  spec.name = 'ruby-text-game'
  spec.version = '0.0.1'
  spec.required_ruby_version = '>= 3.4.1'
  spec.add_dependency 'algorithms', '~> 1.0'
  spec.add_dependency 'logger'
  spec.files = [
    'lib/ruby-text-game.rb',
    'lib/ruby-text-game/command.rb',
    'lib/ruby-text-game/direction.rb',
    'lib/ruby-text-game/events.rb',
    'lib/ruby-text-game/idgen.rb',
    'lib/ruby-text-game/npc.rb',
    'lib/ruby-text-game/object.rb',
    'lib/ruby-text-game/player.rb',
    'lib/ruby-text-game/room.rb',
    'lib/ruby-text-game/world.rb'
  ]
  spec.require_paths = ['lib']
  spec.summary = 'text game lib'
  spec.author = 'Robert O Butts'
end
