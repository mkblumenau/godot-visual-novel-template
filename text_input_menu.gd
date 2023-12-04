extends Control
signal inputSent
var keyToSet = "" # Use this to store what variable the key will go to.

""" This script runs an input menu that lets the player type something in for a variable.
Currently it only returns strings. """

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func commitInput():
	# Send the signal saying that the input was put in.
	# Also set the appropriate variable in the sample scene.
	#get_node('/root/SampleScene').vars[keyToSet] = $VBoxContainer/InputBar.get_text()
	get_node('/root/SampleScene').setVarsEntry(keyToSet, $VBoxContainer/LineEdit.get_text())
	inputSent.emit()


func setUpMenu(title, keyToSetInput):
	$VBoxContainer/MenuName.set_text(title)
	keyToSet = keyToSetInput
	$VBoxContainer/SubmitButton.pressed.connect(commitInput)
	$VBoxContainer/SubmitButton.pressed.connect(queue_free)
	$VBoxContainer/LineEdit.grab_focus()
