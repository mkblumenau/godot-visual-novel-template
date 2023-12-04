extends Control
@export var gameScenePath: String

""" Audio variables """
var musicBus = AudioServer.get_bus_index("Music")
var SFXBus = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/MusicCheckbox.button_pressed = not isMusicMuted()
	$VBoxContainer/SFXCheckbox.button_pressed = not isSFXMuted()
	$VBoxContainer/StartGameButton.grab_focus()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func startGame():
	get_tree().change_scene_to_file(gameScenePath)


# Functions for controlling the audio.

# Return if a bus is muted
func isMusicMuted():
	return AudioServer.is_bus_mute(musicBus)


func isSFXMuted():
	return AudioServer.is_bus_mute(SFXBus)


func setMusicMuted(boolInput):
	AudioServer.set_bus_mute(musicBus, boolInput)


func setSFXMuted(boolInput):
	AudioServer.set_bus_mute(SFXBus, boolInput)


# Use the checkboxes to toggle if it's muted.
func _on_music_checkbox_toggled(button_pressed):
	setMusicMuted(not button_pressed)


func _on_sfx_checkbox_toggled(button_pressed):
	setSFXMuted(not button_pressed)
