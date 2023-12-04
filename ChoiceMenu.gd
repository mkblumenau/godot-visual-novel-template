extends Control
signal choiceMade # emitted when a choice is made

""" This script controls the choice menu.
To use it, instantiate it from the main script.
Make sure it's in the choiceMenuTemplate export variable there. """

# Called when the node enters the scene tree for the first time.
func _ready():
	#$VBoxContainer.add_child(Button.new())
	#setUpMenu("Menu test", [["hide", hide], ["also hide", hide]])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


""" There are three variants of this because they all correspond to different ways
of calling this function.
setUpMenu is intended to be called directly from MainScene.
setUpMenuFromDialogue is for making a menu from a dialogue file
that only goes to other files.
setUpMenuDialogueFunctions is for making a menu from a dialogue file
that calls other functions. """

func setUpMenu(menuName, inputsArray):
	""" Call this to set up the menu. 
	Syntax: menuName is the label for the menu.  
	choicesArray is an array of arrays. 
	Each subarray is formatted as ["string for option name", functionToCallFromButton] """
	$VBoxContainer/MenuName.set_text(menuName)
	for i in inputsArray:
		var newButton = Button.new()
		$VBoxContainer.add_child(newButton)
		newButton.set_text(i[0])
		newButton.set_name(i[0])
		# connect the signal to the button to the function in i[1]
		newButton.pressed.connect(i[1])
		# connect the signal from the button to a function that destroys this
		newButton.pressed.connect(queue_free)
		# connect the button so it emits the signal on this saying that a choice was made
		# this lets the main script wait for a choice to be made
		newButton.pressed.connect(self.emit_signal.bind(choiceMade))
	
	for i in $VBoxContainer.get_children():
		if i is Button:
			i.grab_focus()

	#grab_focus()
	#print("choiceGrab")


func setUpMenuFromDialogue(menuName, inputsArray):
	""" A variant of setUpMenu intended for reading from dialogue files.
	Each choice goes to a different file.  """
	$VBoxContainer/MenuName.set_text(menuName)
	for i in inputsArray:
		var newButton = Button.new()
		$VBoxContainer.add_child(newButton)
		newButton.set_text(i[0])
		newButton.set_name(i[0])
		# connect the signal to the button to run the scene from the specified file
		newButton.pressed.connect(get_node('/root/SampleScene').runSceneFromFile.bind(i[1]))
		# connect the signal from the button to a function that destroys this
		newButton.pressed.connect(queue_free)
		# connect the button so it emits the signal on this saying that a choice was made
		# this lets the main script wait for a choice to be made
		newButton.pressed.connect(self.emit_signal.bind("choiceMade"))
	
	for i in $VBoxContainer.get_children():
		if i is Button:
			i.grab_focus()
	pass


func setUpMenuDialogueFunctions(menuName, inputsArray):
	$VBoxContainer/MenuName.set_text(menuName)
	for i in inputsArray:
		var newButton = Button.new()
		$VBoxContainer.add_child(newButton)
		newButton.set_text(i[0])
		newButton.set_name(i[0])
		# connect the signal to the function call
		newButton.pressed.connect(Callable(get_node('/root/SampleScene'), i[1]))
		# connect the signal from the button to a function that destroys this
		newButton.pressed.connect(queue_free)
		# connect the button so it emits the signal on this saying that a choice was made
		# this lets the main script wait for a choice to be made
		newButton.pressed.connect(self.emit_signal.bind("choiceMade"))
	
	for i in $VBoxContainer.get_children():
		if i is Button:
			i.grab_focus()
	pass
