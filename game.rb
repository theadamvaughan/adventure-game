class Items
  attr_accessor(:name, :description, :item_id, :canBePickedUp, :isPickedUp)

  def initialise(name, description, item_id, canBePickedUp)
    @name = name
    @description = description
    @item_id = item_id
    @canBePickedUp = canBePickedUp
    @isPickedUp = false
  end
end

class Characters
  attr_accessor(:name, :description, :character_id, :canBePickedUp, :isPickedUp)

  def initialise(name, description, character_id, canBePickedUp)
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

  def initialise(name, description, room_id)
    @name = name
    @description = description
    @room_id = room_id
    @isLocked = false
  end
end
