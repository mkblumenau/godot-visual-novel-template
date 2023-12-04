extends Button

"""
This script runs a button that activates only on hover.
It's not included in the base project, but I put it here
in case you want to make imagemaps with it.
"""

@export var hoverColor: Color
@export var nonHoverColor: Color

# Called when the node enters the scene tree for the first time.
func _ready():
	set_modulate(nonHoverColor)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func buttonFocused():
	set_modulate(hoverColor)


func buttonUnfocused():
	set_modulate(nonHoverColor)


func _on_focus_entered():
	buttonFocused()


func _on_mouse_entered():
	buttonFocused()


func _on_focus_exited():
	buttonUnfocused()


func _on_mouse_exited():
	buttonUnfocused()
