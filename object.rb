class Object
  attr_accessor :id
  attr_accessor :word
  attr_accessor :brief_desc
  attr_accessor :long_desc
  def initialize(id, word, brief_desc, long_desc)
    @id = id
    @word = word
    @brief_desc = brief_desc
    @long_desc = long_desc
  end
end

class Weapon < Object
  def initialize(id, word, brief_desc, long_desc, damage, attack_msg_tpl)
    @damage = damage
    @attack_msg_tpl = attack_msg_tpl
    super(id, word, brief_desc, long_desc)
  end

  def attack_msg(second_person, third_person)
    msg = @attack_msg_tpl + ' with ' + @brief_desc + '.'
    msg = format(msg, titleize(second_person), third_person)
    msg
  end
end

class Sword < Weapon
  def initialize(id, brief_desc, long_desc, damage)
    attack_msg_tpl = '%s slice into %s'
    word = 'sword'
    super(id, word, brief_desc, long_desc, damage, attack_msg_tpl)
  end
end

# TODO: put in util func?
def titleize(str)
  str.gsub(/\w+/) do |word|
    word.capitalize
  end
end
