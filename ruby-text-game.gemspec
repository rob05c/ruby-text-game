Gem::Specification.new do |spec|
  spec.name = 'ruby-text-game'
  spec.version = '0.0.1'
  spec.required_ruby_version = '>= 3.4.1'
  spec.add_dependency 'algorithms', '~> 1.0'
  s.files = [
    'command.rb',
    'direction.rb',
    'events.rb',
    'idgen.rb',
    'npc.rb',
    'object.rb',
    'player.rb',
    'room.rb',
    'world.rb'
  ]
  s.require_paths = ['lib']
  spec.summary = 'text game lib'
  spec.author = 'Robert O Butts'
end
