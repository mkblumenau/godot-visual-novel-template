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


func setUpMenu(menuName, inputsArray, functionMode):
	""" Sets up the menu based on name and choices. 
	functionMode can take 3 options: 
		callable- if the inputs array has callables
		jumpfile- if the inputs array has names of files to jump to
		string- if the inputs array has names of callables in string format
	"""
	
	$VBoxContainer/MenuName.set_text(menuName)
	for i in inputsArray:
		var newButton = Button.new()
		$VBoxContainer.add_child(newButton)
		newButton.set_text(i[0])
		newButton.set_name(i[0])
		
		match functionMode:
			# Connect the button to its function depending on what kind of function it is.
			"callable":
				newButton.pressed.connect(i[1])
			
			"jumpfile":
				newButton.pressed.connect(get_node('/root/SampleScene').runSceneFromFile.bind(i[1]))
				
			"string":
				newButton.pressed.connect(Callable(get_node('/root/SampleScene'), i[1]))

		# connect the signal from the button to a function that destroys this
		newButton.pressed.connect(queue_free)
		
		# connect the button so it emits the signal on this saying that a choice was made
		# this lets the main script wait for a choice to be made
		newButton.pressed.connect(self.emit_signal.bind("choiceMade"))
	
	for i in $VBoxContainer.get_children():
		if i is Button:
			i.grab_focus()
