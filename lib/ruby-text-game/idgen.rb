module RubyTextGame
  class IdGenerator
    def initialize
      @next_id = 0
      puts 'IdGenerator.initialize'
    end

    def get
      @next_id += 1
      @next_id
    end
  end
end
