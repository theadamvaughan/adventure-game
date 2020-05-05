class Item
  attr_accessor(:name, :description, :item_id, :canBePickedUp, :isPickedUp)

  def initialize(name, description, item_id, canBePickedUp)
    @name = name
    @description = description
    @item_id = item_id
    @canBePickedUp = canBePickedUp
    @isPickedUp = false
  end
end

class Character
  attr_accessor(:name, :description, :character_id, :canBePickedUp, :isPickedUp)

  def initialize(name, description, character_id, canBePickedUp)
    @name = name
    @description = description
    @character_id = character_id
    @canBePickedUp = canBePickedUp
    isPickedUp = false
  end

  def talk
    puts "Hello there!"
  end
end

class Room
  attr_accessor(:name, :description, :room_id, :isLocked)

  def initialize(name, description, room_id)
    @name = name
    @description = description
    @room_id = room_id
    @isLocked = false
  end
end

player1 = Character.new("Adam", "Our handsome protagonist", 1, false)
player1.talk