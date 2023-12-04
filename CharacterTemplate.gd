extends Control

""" This script is attached to a prefab that's used to add new characters to the game. """

@export var characterName: String
@export var characterTag: String
@export var characterColor: Color

@export_category("Text body font features")
@export var textBold: bool = false
@export var textItalic: bool = false
@export var customTextFontUsed: bool = false
@export var customTextFontPath: String

@export_category("Opacity settings")
@export var opacitySpeaking: float = 1
@export var opacityNotSpeaking: float = 0.5


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func showAnimation(animationName):
	$SpriteRenderer.play(animationName)


# Set the opacity of the character depending on if they're speaking.
func setSpeakingOpacity():
	modulate = Color(1, 1, 1, opacitySpeaking)
	

func setNotSpeakingOpacity():
	modulate = Color(1, 1, 1, opacityNotSpeaking)


func setPositionFraction(newPercentFloat):
	""" Sets the character's x (width) position onscreen.
	0 = all the way left
	1 = all the way right """
	var screenWidth = ProjectSettings.get_setting("display/window/size/viewport_width")
	set_position(Vector2(screenWidth * newPercentFloat, get_position().y))


# Fade the character in or out in a given number of seconds.
# This will always fade from 1, even if the opacity was previously something else.
func fadeIn(timeInSeconds):
	$AnimationPlayer.speed_scale = float(1.0 / float(timeInSeconds))
	$AnimationPlayer.play("fade_in_1")


func fadeOut(timeInSeconds):
	$AnimationPlayer.speed_scale = float(1.0 / float(timeInSeconds))
	$AnimationPlayer.play("fade_out_1")
