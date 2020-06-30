class Room

  attr_accessor(:name, :description, :id, :isLocked)

  def initialize(name, description, id, isLocked)
    @name = name
    @description = description
    @id = id
    @isLocked = isLocked
  end

end

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


class Game


  def find_room_by_id(id)
    @rooms.each do |room|
      return room if room.id == id
    end
  end

  def find_item_by_id(id)
    @items.each do |item|
      puts item
      return item if item.item_id == id
    end
  end

  def items_i_can_currently_use
    item_combos = []
    @use_combos.each do |combo|
      item_combos << combo if @inventory.include?(combo[:item_id]) && combo[:usage_location] == @current_room_index
    end
    item_combos
  end

  def print_things_i_can_currently_use
    items_i_can_currently_use.each do |combo|
      puts combo[:message]
      puts find_item_by_id(combo[:item_id]).description
    end
  end



def initialize

  @items = [
    Item.new("Mouse", "A cute tiny mouse. Who could be afraid of this?", 1, true),
    Item.new("Desk", "A metal desk. Flat metal top and 4 metal legs.", 2, false),
    Item.new("Chair", "A metal chair with 4 legs", 3, false),
    Item.new("Bed", "A metal bed with a thin pillow and a tatty waffer thin blanket", 4, false),
    Item.new("Cheese Sandwich", "A mouldy cheese sandwich. No human would want to eat this", 5, true),
    Item.new("Prison Guard", "He's a large man, clearly been eating too many pies", 6, false),
    Item.new("Prison Keys", "A bunch of keys that open all the cells and the cell room main door", 7, true),
    Item.new("Bobby Pin", "Good for holding back hair and picking locks", 8, true)
  ].freeze

#  generating the rooms

  @rooms = [
    Room.new("Your Cell", "It's a dirty room with no windows. It contains a bed, chair and desk. There's a mouse in the corner of the room.", 9, true), 
    Room.new("Cell 2", "It's the prison cell next to yours. It's the same as yours but there's a female prison inside.", 10, false),
    Room.new("Cell 3", "It's the prison cell opposite yours. It open with nothing in it except a bed, chair and desk. On the desk appears to be a sandwich", 11, false),
    Room.new("the Prison Hallway", "At one end of the Prison Hallway is your cell and two others. At the other end sits a prison guard. The prison guard is asleep.", 12, false)
  ].freeze

  @use_combos = [
    { item_id: 8, target_id: 9, usage_location: 9, message: "You use the bobby pin to unlock your cell." },
    { item_id: 5, target_id: 1, usage_location: 9, message: "You use the cheese sandwich to tempt the mouse and pick him up." },
    { item_id: 1, target_id: 6, usage_location: 12, message: "You release the mouse who runs towards the guard." },
    { item_id: 7, target_id: 10, usage_location: 12, message: "You use the prison keys to open the cell 2 to release the female prisoner" },
    { item_id: 7, target_id: 12, usage_location: 12, message: "You use the prison keys to open the main prison hallway door. you escape to wherever" }
  ]

  @inventory = [1, 8, 5]
  @game_complete = false
  @current_room_index = 9
  @starting_game_text = true

  @cell1_items = [1, 2, 3, 4, 8]
  @cell2_items = [2, 3, 4]
  @cell3_items = [2, 3, 4, 5]
  @prison_hallway_items = [2, 6, 7]

end
# Starting game

  def play
    while @game_complete == false

      # starting game text to help the player create a mental picture of the environment

      puts "What would you like to do?\n"

      # print out players command options

      puts "[U] Use item"

      # gets user input

      input = gets.chomp

        if input.downcase == "u"
          print_things_i_can_currently_use
        
        elsif input.downcase == "q"
          @game_complete = true

        else
          puts "\nI don't know that command\n"
        end

    end
  end

end


game = Game.new
game.play