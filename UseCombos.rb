require "tty-prompt"

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
  attr_accessor(:name, :description, :item_id, :canBePickedUp, :isPickedUp, :pick_up_dependency_met, :show_item)

  def initialize(name, description, item_id, canBePickedUp, pick_up_dependency_met = true, show_item = true)
    @name = name
    @description = description
    @item_id = item_id
    @canBePickedUp = canBePickedUp
    @isPickedUp = false
    @pick_up_dependency_met = pick_up_dependency_met
    @show_item = show_item
  end

end

# MIGHT USE THESE CLASSES LATER ON

class Person < Item
  
  def initialize(name, description, item_id, canBePickedUp)
    super(name, description, item_id, canBePickedUp)
  end

end

# class Animal < Item

#   def initialize(name, description, item_id, canBePickedUp)
#     @is_wary = true
#     super(name, description, item_id, canBePickedUp)
#   end

# end


class Game

# ................. GAME STYLING - PAUSES AND SLOW TYPE

  def pause(input)
    $stdout.flush
    sleep input
  end

  def slow_type(text)

    if !@debug
      text.each_char {|c| putc c ; sleep 0.04; $stdout.flush }
      pause(0.8)
      puts "\n"
    else
      puts text
    end

  end

# ................. TEXT AT THE START OF THE GAME


  def player_set_up

    if @debug == false
      system('clear')
      slow_type("Please enter your name and hit enter:")
      @new_player_name = gets.chomp
      slow_type("\nThank you, #{@new_player_name}")
      slow_type("\nTime to start the game...\n")
    end
    
  end

  def starting_game_text
    slow_type("\nAs you slowly start to regain consciousness, you feel the coldness of the floor and the damp in the air.") 
    slow_type("As your eyes slowly open and focus on your surroundings, you notice that you are in a prison cell.")
    slow_type("The cell has bars at the front. The sides and the back of the cell are made of metal.")
    slow_type("You're in the corner cell of a cell block. You have no idea how you got there.")
    slow_type("You look around your cell. #{find_room_by_id(@current_room_id).description}")
    slow_type("In the corner you notice a small mouse sat outside a small hole in the wall.")
    slow_type("Looking through the cell bars you notice there's two other cells. One is directly opposite yours, and one is next to yours.")
    slow_type("The cells are at the end of a prison hallway. At the other end is the exit.")
    slow_type("There's a guard at the end of the prison hallway blocking the exit. He's sitting next to a desk and is asleep.")
    slow_type("You need to find out how you got there but first, you must find a way out of the prison cell block.")
  end

# ................. GAME COMPELETE TEXT

  def game_complete_text
    slow_type("\nCongratulations, #{@new_player_name}! You have found your way out!")
    pause(0.5)
    slow_type("Written, developed and coded by Adam Vaughan and Danny Smith.")
    pause(0.5)
    slow_type("Stayed tuned for more levels!")
  end

# .................. ADDITIONAL TEXT

  def additional_text
    if @current_room_id == 11 && !@inventory.include?(5)
      slow_type("On the desk appears to be a sandwich.")
    elsif @current_room_id == 12 && (find_item_by_id(7).pick_up_dependency_met == false)
      slow_type("At the other end sits a prison guard. The prison guard is asleep.")
    elsif @current_room_id == 12 && (find_item_by_id(7).pick_up_dependency_met == true)
      slow_type("Near the exit the Prison Guard is unconscious on the floor.")
    else
      return nil
    end
  end

# ................ CONTROLS HOW AND IF THE PLAYER CAN MOVE

  def player_move

    move = TTY::Prompt.new

    choices = []
    @options = []
    @rooms.each do |room|
      @options << room.id
      choices << { name: room.name, value: room.id } unless room.id == @current_room_id
    end

    input = move.select(slow_type("Where would you like to move to?"), choices)

    pause(0.5)

    if @options.include?(input) && find_room_by_id(@current_room_id).isLocked
        slow_type("#{find_room_by_id(@current_room_id).name} is locked, you'll need to find a way out") 

    elsif @options.include?(input) && find_room_by_id(input.to_i).isLocked
        slow_type("You cannot get to #{find_room_by_id(input.to_i).name}. it is currently locked")

    elsif @options.include?(input) && !find_room_by_id(@current_room_id).isLocked

        @current_room_id = input
        slow_type("\nYou have moved to #{find_room_by_id(@current_room_id).name}")
        slow_type("#{find_room_by_id(@current_room_id).description}")
        additional_text
    elsif input.to_s.downcase == "q"
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
    return nil
  end

# ......LOCATING ITEMS BASED OFF ITEM_ID

  def find_item_by_id(id)

    @items.each do |item|
      return item if item.item_id == id
    end
    return nil
  end

# ........THIS CODE PRINTS OUT THE ITEMS IN THE ROOM 
  
  def current_cell_items
    @cell_items[@current_room_id]
  end

  def print_out_room_items

    current_cell_items.each do |item_id|
      item = find_item_by_id(item_id)
      puts "#{item.name} - #{item.description}" unless @inventory.include?(item.item_id) || item.show_item == false || item.class == Person
    end

  end

# ....... CODE ADDS ITEMS INTO YOUR INVENTORY

  def put_item_in_inventory(input)

    if find_item_by_id(input).canBePickedUp
      unless @inventory.include?(input)
        @inventory << input
        slow_type("\nYou have picked up the #{find_item_by_id(input).name}.")
      end

    else
      slow_type("You cannot pick up this item")
    end

  end

# ......THE CODE THAT MAKES YOU PICK THINGS UP

  def pick_up

    slow_type("\nHere's what's in #{find_room_by_id(@current_room_id).name}:\n")

    current_cell_items.each do |item_id|
      item = find_item_by_id(item_id)
      puts "#{item.name}" unless @inventory.include?(item.item_id) || item.show_item == false || item.class == Person
    end
    
    pick_up = TTY::Prompt.new

    choices = []
    @options = []
    current_cell_items.each do |item_id|
      item = find_item_by_id(item_id)
      choices << { name: item.name, value: item.item_id } unless @inventory.include?(item.item_id) || item.show_item == false || item.class == Person
    end
    
    input = pick_up.select(slow_type("\nWhat would you like to pick up?\n"), choices)

    # RUN PICK UP RULES TO CHECK IF WE CAN PICK IT UP

    if @inventory.include?(input) || input == 0
      slow_type("\nI don't know that command.")

    elsif find_item_by_id(input).show_item == false
      slow_type("\nI don't know that command.")
    
    elsif current_cell_items.include?(input) && !@inventory.include?(input)
      pick_up_checks(input)

    elsif current_cell_items.include?(input) && !@inventory.include?(input)
      put_item_in_inventory(input)
    else
      slow_type("\nI don't know that command.")
    end
  end

# .......... THIS CODE CHECKS IF PICK UP DEPENDENCIES HAVE BEEN MET

  def pick_up_checks(input)
      
    if find_item_by_id(input).pick_up_dependency_met
      put_item_in_inventory(input)

    else
      @pick_up_rules.each do |rule|
        slow_type("#{rule[:message]}") if rule[:item_id] == input
        reset_game if input == 7 
      end
    end

  end

# .......... LOOK AT CODE AND PRINTING INVENTORY

  def look_at
    pause(0.25)

    look_at = TTY::Prompt.new

    choices = [
      { name: 'Inventory Item', value: 1 },
      { name: 'Whats in the Room', value: 2 },
    ]
    
    input = look_at.select(slow_type("\nWhat would you like to look at?\n"), choices)

    pause(0.5)

    if input == 1
      look_at_inventory

    elsif input == 2
      slow_type("\nHere's what's in #{find_room_by_id(@current_room_id).name}:\n")
      print_out_room_items

    elsif input.downcase == "q"
      @game_complete = true
    
    else 
      slow_type("\nI don't know that command")
      look_at
    end

  end

  def look_at_inventory

    if @inventory.empty?
      slow_type("\nYou don't have anything in your inventory")
    else
      print_inventory_items
    end

  end

  def print_inventory_items

    slow_type("\nHere are your inventory items;\n")

    @inventory.each do |item_id|
      item = find_item_by_id(item_id)
      puts "#{item.name} - #{item.description}"
    end

  end

# ........... CODE TO USE ITEMS 

  def use_item

    if @inventory.empty?
      slow_type("\nYou don't have anything in your inventory")

    else
      print_inventory_items

      use_item = TTY::Prompt.new

      choices = []
      @options = []
      @inventory.each do |item_id|
      inventory_item = find_item_by_id(item_id)
        choices << { name: inventory_item.name, value: inventory_item.item_id }
      end

      item_id = use_item.select(slow_type("\nWhat would you like to use?"), choices)
      
      selected_item = find_item_by_id(item_id)

      if @inventory.include?(item_id)
    
        use_on = TTY::Prompt.new

        choices = []
        @options = []
        current_cell_items.each do |item_id|
          item = find_item_by_id(item_id)
          choices << { name: item.name, value: item.item_id } unless @inventory.include?(item.item_id) || item.show_item == false || item.class == Person
        end

        target_item = use_on.select(slow_type("\nWhat would you like to use the #{selected_item.name} on?"), choices)

        combo = @use_combos.find { |combo| combo[:item_id] == item_id && combo[:usage_location] == @current_room_id && combo[:target_id] == target_item}
        
        if combo.nil?
          slow_type("\nYou cannot use these two items together") 
          
        else 
          use_item_dependency(item_id)
          slow_type(combo[:message])

          if combo[:cell_to_unlock]
            find_room_by_id(combo[:cell_to_unlock]).isLocked = false
            game_complete if combo[:game_complete]
          end

        end
        # need it to perform the action
        # change the state of the target item if necessary
        # remove item from inventory (sometimes)
      else
        slow_type("\nyou cannot use that item")
      end
    end
  end

  def use_item_dependency(input)
    
    @pick_up_rules.each do |rule|
      if rule[:depends_on] == input
        find_item_by_id(rule[:item_id]).pick_up_dependency_met = true
      end
    
    find_item_by_id(input)
    # when we use an item it might need to change the pick_up_dependency
    end
    
  end

  def items_use_combos

    @use_combos.each do |combo|
      puts combo[:message] if @inventory.include?(combo[:item_id]) && combo[:usage_location] == @current_room_id
    end

  end

# ............ DISCUSSION WITH LIBERTY

  def talk_to

    talk_to = TTY::Prompt.new
    choices = []

    unless !current_cell_items.include?(18)
      @items.each do |is_person|
        choices << { name: is_person.name, value: is_person.item_id } if is_person.class == Person && current_cell_items.include?(is_person.item_id)
      end
    
    input = talk_to.select(slow_type("\nWho do you want to talk to?"), choices)

      if input == 18
        liberty_discussion
      else
        slow_type("I don't know that command")
      end
    else
      slow_type("There's no-one here for you to speak to.")
    end
  end


  def liberty_discussion
    
    @liberty_conversation = [

      { talk_id: 1, next_talk_id: 2, character: @new_player_name, message: "Hey! Lady in the cell next to me! What's going on?" },
      { talk_id: 2, next_talk_id: 3, character: "Liberty", message: "Hey there! I was wondering when you were going to wake up! My name is Liberty. What brings you here?" },
      { talk_id: 3, next_talk_id: 5, character: @new_player_name, message: "I don't know, I'm not sure how I got here. Where are we?" },
      { talk_id: 4, next_talk_id: 7, character: @new_player_name, message: "Fuck knows, all I know is that I have a pounding headache. Any idea how I got here?" },
      { talk_id: 5, next_talk_id: 6, character: "Liberty", message: "You're onboard the Spaceship Caerus. It’s a holding vessel for the Ahrimanian Empire." },
      { talk_id: 6, next_talk_id: 7, character: @new_player_name, message: "Great. Any idea how or why I got here?" },
      { talk_id: 7, next_talk_id: 9, character: "Liberty", message: "No idea what you have been bought in here for. Although I did hear one of the guards mutter something about finding your spaceship floating in space." },
      { talk_id: 8, next_talk_id: 5, character: @new_player_name, message: "So what is this place?" },
      { talk_id: 9, next_talk_id: 10, character: @new_player_name, message: "Perfect. So what did you do to end up here?" },
      { talk_id: 10, next_talk_id: 11, character: "Liberty", message: "I got caught salvaging parts from an abandoned space outpost. It was out of their jurisdiction but they decided to pick me up anyway." },
      { talk_id: 11, next_talk_id: 12, character: @new_player_name, message: "Looks like we're doomed. Anything I can hang myself with?" },
      { talk_id: 12, next_talk_id: 13, character: "Liberty", message: "You could try and use my shoelaces, but I don't think that's a good idea." },
      { talk_id: 13, next_talk_id: 14, character: @new_player_name, message: "Know of a way to get out?" },
      { talk_id: 14, next_talk_id: 15, character: "Liberty", message: "The place looks well sealed to me. If you can find a way of getting the keys off the guards desk you can bust us out." },
      { talk_id: 15, next_talk_id: 16, character: @new_player_name, message: "Looks too far away and there's no way of reaching it. If you have something small and thin, I could try and pick the lock on my cell door." },
      { talk_id: 16, next_talk_id: 17, character: "Liberty", message: "My hair is held back with bobby pins, would one of those do?" },
      { talk_id: 17, next_talk_id: 19, character: @new_player_name, message: "Yeah, that could work. Chuck one into my cell." },
      { talk_id: 18, next_talk_id: 19, character: @new_player_name, message: "Hey, Liberty, any chance of another Bobby Pin?" },
      { talk_id: 19, next_talk_id: 20, character: "Liberty", message: "Sure, here you go" },
      { talk_id: 20, next_talk_id: 20, character: "Liberty", message: "Hurry up and bust us out of here already!" },
      { talk_id: 21, next_talk_id: 21, character: "Liberty", message: "Thanks for setting me free! I owe you one!" }
    ]

    if @liberty_discussion_is_complete == false
      
      @talk_id = 1

      until @liberty_discussion_is_complete == true

        message = @liberty_conversation.find { |message| message[:talk_id] == @talk_id }
        print "#{message[:character]}: "
        slow_type("#{message[:message]}")
        @talk_id = message[:next_talk_id]

        # Conversation stops when it gets to the end. set conversation_complete to tru so you don't have to go through the same dialogue
        # The bobby pin becomes viewable
        # sets the @talk_id to 21

        if message[:talk_id] == 19

          @liberty_discussion_is_complete = true
          find_item_by_id(8).show_item = true
          @talk_id = 20

        end
      end
      # reset_game sets the dialogue tree to 18 so you can ask for another bobby pin

    elsif find_room_by_id(10).isLocked == false
      @talk_id = 21

      message = @liberty_conversation.find { |message| message[:talk_id] == @talk_id }
      print "#{message[:character]}: "
      slow_type("#{message[:message]}")

    elsif @talk_id == 18

      until @talk_id == 20

        message = @liberty_conversation.find { |message| message[:talk_id] == @talk_id }
        print "#{message[:character]}: "
        slow_type("#{message[:message]}")
        @talk_id = message[:next_talk_id]
        find_item_by_id(8).show_item = true

      end

      # If @talk_id is 20

    else @talk_id == 20

      message = @liberty_conversation.find { |message| message[:talk_id] == @talk_id }
      print "#{message[:character]}: "
      slow_type("#{message[:message]}")

    end

  end

# ............ RESET GAME AND GAME COMPLETE CODE

  def reset_game
    @current_room_id = 9
    find_room_by_id(9).isLocked = true
    find_item_by_id(8).show_item = false
    @inventory.delete(8)
    @talk_id = 18
  end

  def game_complete
    game_complete_text
    @game_complete = true
  end

# ...... GAME INITIALIZING

  def initialize

    @items = [
      Item.new("Mouse", "A cute tiny mouse. Who could be afraid of this?", 1, true, false),
      Item.new("Desk", "A metal desk. Flat metal top and 4 metal legs.", 2, false),
      Item.new("Chair", "A metal chair with 4 legs", 3, false),
      Item.new("Bed", "A metal bed with a thin pillow and a tatty waffer thin blanket", 4, false),
      Item.new("Cheese Sandwich", "A mouldy cheese sandwich. No human would want to eat this", 5, true),
      Item.new("Prison Guard", "He's a large man, clearly been eating too many pies", 6, false),
      Item.new("Prison Keys", "A bunch of keys that open all the cells and the cell room main door", 7, true, false),
      Item.new("Bobby Pin", "Good for holding back hair and picking locks", 8, true, true, false),
      Item.new("Your Cell Door", "Made of steel and looks pretty sturdy", 14, false),
      Item.new("Cell 2 Door", "Made of steel and looks pretty sturdy", 15, false),
      Item.new("Cell 3 Door", "Made of steel and looks pretty sturdy", 16, false),
      Item.new("Door to the Outside World", "Huge metal door with a small window", 17, false),
      Person.new("Liberty", "Female prisoner from the cell next to you", 18, false)
    ].freeze

# ....... GENERATING ROOMS

    @rooms = [
      Room.new("Your Cell", "It's a dirty room with no windows. It contains a metal Bed, Chair and Desk.", 9, true), 
      Room.new("Cell 2", "It's the prison cell next to yours. It's the same as yours but there's a female prisoner inside.", 10, true),
      Room.new("Cell 3", "It's the prison cell opposite yours. It open with nothing in it except a bed, chair and desk.", 11, false),
      Room.new("The Prison Cell Holding Area", "At one end of the Prison Hallway is your cell and two others.", 12, false),
      Room.new("The Outside World", "You'll need to find a way to get here", 13, true)
    ]

# ......... CODE THAT DETERMINES WHAT ITEMS CAN BE USED TOGETHER

    @use_combos = [
      { item_id: 8, target_id: 14, usage_location: 9, message: "\nYou have used the Bobby Pin to unlock your Cell. You gently open the door so you do not wake up the guard.", cell_to_unlock: 9},
      { item_id: 5, target_id: 1, usage_location: 9, message: "\nYou have used the Cheese Sandwich to tempt the Mouse over to you. He seems fairly calm eating the cheese." },
      { item_id: 1, target_id: 6, usage_location: 12, message: "\nYou take the Mouse out of your pocket and it runs towards the guard. The guard screams and runs directly into the wall, knocking himself out"},
      { item_id: 7, target_id: 15, usage_location: 12, message: "\nYou use the Prison Keys to open the cell 2 and set Liberty free", cell_to_unlock: 10 },
      { item_id: 7, target_id: 17, usage_location: 12, message: "\nYou use the Prison Keys to open the main Prison Hallway door. You escape to level 2...", cell_to_unlock: 13, game_complete: true }
    ]

# .......... CODE FOR WHEN PICK UP DEPENDENCIES HAVEN'T BEEN MET

    @pick_up_rules = [
      { item_id: 1, depends_on: 5, message: "\nThe Mouse gets scared and runs into a hole in the wall. You'll need to find a way to tempt him out." },
      { item_id: 7, depends_on: 1, message: "\nWhen you reach over to pick up the Prison Keys you wake up the guard. \nThe Guard grabs you and puts you back in Your Cell before heading back to his chair and falling asleep.", reset_game: true }
    ]

# .......... GENERATES THE ITEMS IN EACH CELL

    @cell_items = {
      9 => [1, 2, 3, 4, 8, 14, 18],
      10 => [2, 3, 4, 15, 18],
      11 => [2, 3, 4, 5, 16],
      12 => [2, 6, 7, 14, 15, 16, 17, 18]
    }

# .......... STARTING GAME SETTING

    @inventory = []
    @game_complete = false
    @current_room_id = 9
    @starting_game_text = true
    @current_cell_items = @cell1_items
    @liberty_discussion_is_complete = false

# .......... SET DEBUG TO TRUE IF CODE BUILDING/DEBUGGING

    @debug = true

  end

# ...... STARTING THE GAME 

  def play

    while @game_complete == false

      # starting game text to help the player create a mental picture of the environment
      @new_player_name = "Mr Developer" if @debug
      player_set_up unless @debug || @starting_game_text == false
      puts starting_game_text unless @debug  || @starting_game_text == false
      @starting_game_text = false
      
      slow_type("\nYou are in #{find_room_by_id(@current_room_id).name}")
      main_menu = TTY::Prompt.new

      choices = [
      { name: 'Move Player', value: 1 },
      { name: 'Look At', value: 2 },
      { name: 'Pick Up', value: 3 },
      { name: 'Use Item', value: 4 },
      { name: 'Talk To', value: 5 },
      { name: 'Quit', value: 6 },
    ]
      attr = main_menu.select(slow_type("What would you like to do?"), choices)

      # gets user input
        
      if attr == 1
        player_move
        
      elsif attr == 2
        look_at

      elsif attr == 3
        pick_up

      elsif attr == 4
        use_item

      elsif attr == 5
        talk_to
      
      elsif attr == 6
        @game_complete = true

      else
        puts "\nI don't know that command\n"
      end

    end
  end

end


game = Game.new
game.play