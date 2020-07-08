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

  def pause(input)
    $stdout.flush
    sleep input
  end

  def slow_type(text)
    @debug = true

    if !@debug
      text.each_char {|c| putc c ; sleep 0.04; $stdout.flush }
      pause(1)
      puts "\n"
    else
      puts text
    end

  end

  def player_move
    @options = []
    slow_type("\nWhere would you like to move to?\n")

    @rooms.each do |room|
      @options << room.id
      puts "[#{room.id}] #{room.name}" unless room.id == @current_room_id
    end

    input = gets.chomp
    pause(0.5)

    if @options.include?(input.to_i) && find_room_by_id(@current_room_id).isLocked
        slow_type("#{find_room_by_id(@current_room_id).name} is locked, you'll need to find a way out") 

    elsif @options.include?(input.to_i) && find_room_by_id(input.to_i).isLocked
        slow_type("You cannot get to #{find_room_by_id(input.to_i).name}. You'll need to find a way to escape")

    elsif @options.include?(input.to_i) && !find_room_by_id(@current_room_id).isLocked

        @current_room_id = input.to_i
        slow_type("\nYou have moved to #{find_room_by_id(@current_room_id).name}")
        slow_type("#{find_room_by_id(@current_room_id).description}")

    elsif input.downcase == "q"
      @game_complete = true

    else
      slow_type("I don't know that command\n")
    end

  end

# ......FINDING ROOMS

  def find_room_by_id(id)
    @rooms.each do |room|
      return room if room.id == id
    end
  end


def look_at
  pause(0.5)
  slow_type("\nWhat would you like to look at?\n\n")
  puts "[I] Inventory item"
  puts "[R] Whats in the room"

  input = gets.chomp
  pause(0.5)

  if input.downcase == "i"
    look_at_inventory

  elsif input.downcase == "r"
    print_out_room_items

  elsif input.downcase == "q"
    @game_complete = true
  
  else 
    slow_type("\nI don't know that command")
    look_at
  end

end

# ......FINDING ITEMS AND PRINTING OUT CELL ITEMS

  def find_item_by_id(id)

    @items.each do |item|
      return item if item.item_id == id
    end

  end

# ........THIS CODE PRINTS OUT THE ITEMS IN THE ROOM 

  def current_cell_items
    @cell_items[@current_room_id]
  end

  def print_out_room_items

    current_cell_items.each do |item_id|
      item = find_item_by_id(item_id)
      puts "[#{item.item_id}] #{item.name} - #{item.description}" unless @inventory.include?(item.item_id)
    end

  end

# ......THE CODE THAT MAKES YOU PICK THINGS up

def put_item_in_inventory(input)

  if find_item_by_id(input).canBePickedUp
    unless @inventory.include?(input)
      @inventory << input
      puts "You have picked up the #{find_item_by_id(input).name}"
    end

  else
    slow_type("You cannot pick up this item")
  end
end

def pick_up

  slow_type("Here's what's in the room")

  current_cell_items.each do |item_id|
    item = find_item_by_id(item_id)
    puts "[#{item.item_id}] #{item.name}" unless @inventory.include?(item.item_id)
  end

  slow_type("What would you like to pick up?")
  input = gets.chomp.to_i

  if current_cell_items.include?(input) && !@inventory.include?(input)
    put_item_in_inventory(input)

  else
    slow_type("I don't know that command")
  end
end

# ......EVERYTHING BELOW IS INVENTORY RELATED

  def look_at_inventory

    if @inventory.empty?
      puts "You don't have anything in your inventory"
    else
      print_inventory_items
    end

  end

  def print_inventory_items
    slow_type("\nHere are your inventory items;\n")
    @inventory.each do |item_id|
      item = find_item_by_id(item_id)
      puts "[#{item.item_id}] #{item.name} - #{item.description}"
    end
  end

# ....... USE items_use_combos

  def use_item
    if @inventory.empty?
      slow_type("You don't have anything in your inventory")
    else
      print_inventory_items

      slow_type("what would you like to use?")
      item_id = gets.chomp.to_i

      if @inventory.include?(item_id)
        slow_type("What would you like to use the item on?")

        print_out_room_items
        target_item = gets.chomp.to_i

        combo = @use_combos.find { |combo| combo[:item_id] == item_id && combo[:usage_location] == @current_room_id && combo[:target_id] == target_item}
        if combo.nil?
          slow_type("You cannot use these two items together") 

        else 
          slow_type(combo[:message])
          if combo[:cell_to_unlock]
            find_room_by_id(combo[:cell_to_unlock]).isLocked = false
          end

        end
        # need it to perform the action
        # change the state of the target item if necessary
        # remove item from inventory (sometimes)
      else
        slow_type("you cannot use that item")
      end
    end
  end

  def items_use_combos
    @use_combos.each do |combo|
      puts combo[:message] if @inventory.include?(combo[:item_id]) && combo[:usage_location] == @current_room_id
    end
  end

  def use_inventory_item()

    items_use_combos.each do |combo|
      puts combo[:message] 
      puts find_item_by_id(combo[:item_id]).description 
    end
    
  end

# ......GAME INITIALIZING

  def initialize

    @items = [
      Item.new("Mouse", "A cute tiny mouse. Who could be afraid of this?", 1, true),
      Item.new("Desk", "A metal desk. Flat metal top and 4 metal legs.", 2, false),
      Item.new("Chair", "A metal chair with 4 legs", 3, false),
      Item.new("Bed", "A metal bed with a thin pillow and a tatty waffer thin blanket", 4, false),
      Item.new("Cheese Sandwich", "A mouldy cheese sandwich. No human would want to eat this", 5, true),
      Item.new("Prison Guard", "He's a large man, clearly been eating too many pies", 6, false),
      Item.new("Prison Keys", "A bunch of keys that open all the cells and the cell room main door", 7, true),
      Item.new("Bobby Pin", "Good for holding back hair and picking locks", 8, true),
      Item.new("Your Cell Door", "Made of steel and looks pretty sturdy", 14, false),
      Item.new("Cell 2 Door", "Made of steel and looks pretty sturdy", 15, false),
      Item.new("Cell 3 Door", "Made of steel and looks pretty sturdy", 16, false),
      Item.new("Door to the Outside World", "Huge metal door with a small window", 17, false)
    ].freeze

  #  generating the rooms

    @rooms = [
      Room.new("Your Cell", "It's a dirty room with no windows. It contains a bed, chair and desk. There's a mouse in the corner of the room.", 9, true), 
      Room.new("Cell 2", "It's the prison cell next to yours. It's the same as yours but there's a female prison inside.", 10, true),
      Room.new("Cell 3", "It's the prison cell opposite yours. It open with nothing in it except a bed, chair and desk. On the desk appears to be a sandwich", 11, false),
      Room.new("The Prison Cell Holding Area", "At one end of the Prison Hallway is your cell and two others. At the other end sits a prison guard. The prison guard is asleep.", 12, false),
      Room.new("The Outside World", "You'll need to find a way to get here", 13, true)
    ]

    @use_combos = [
      { item_id: 8, target_id: 14, usage_location: 9, message: "You have used the bobby pin to unlock your cell.", cell_to_unlock: 9},
      { item_id: 5, target_id: 1, usage_location: 9, message: "You have used the cheese sandwich to tempt the mouse and pick him up." },
      { item_id: 1, target_id: 6, usage_location: 12, message: "You take the mouse out of your pocket and it runs towards the guard." },
      { item_id: 7, target_id: 10, usage_location: 12, message: "You use the prison keys to open the cell 2 to release the female prisoner", cell_to_unlock: 10 },
      { item_id: 7, target_id: 13, usage_location: 12, message: "You use the prison keys to open the main prison hallway door. you escape to wherever", cell_to_unlock: 11 }
    ]

    @cell_items = {
      9 => [1, 2, 3, 4, 8, 14],
      10 => [2, 3, 4, 15],
      11 => [2, 3, 4, 5, 16],
      12 => [2, 6, 7, 17]
    }

    @inventory = []
    @game_complete = false
    @current_room_id = 9
    @starting_game_text = true
    @current_cell_items = @cell1_items

  end

  # Starting game

  def play
    while @game_complete == false

      # starting game text to help the player create a mental picture of the environment

      puts "What would you like to do?\n"

      # print out players command options

      puts "[M] Move player"
      puts "[L] Look at"
      puts "[U] Use item"
      puts "[P] Pick up"

      # gets user input

      input = gets.chomp
        
        if input.downcase == "m"
          player_move

        elsif input.downcase == "l"
          look_at

        elsif input.downcase == "p"
          pick_up

        elsif input.downcase == "u"
          use_item
        
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