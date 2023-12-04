extends Node

""" This script is used to play the sounds.
There's one player for music and one for sound effects.
Both are monophonic, so when a song or sound effect is called to play
it will stop whatever's currently playing.
Remember to make sure any audio file is set to loop or not loop
depending on how you want it to behave. """

""" Audio variables """
var musicBus = AudioServer.get_bus_index("Music")
var SFXBus = AudioServer.get_bus_index("SFX")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Change the file extensions in here if your project uses different ones.
func playMusic(inputString):
	var song : AudioStream = load("res://audio/music/" + inputString + ".mp3")
	$MusicPlayer.set_stream(song)
	$MusicPlayer.play()


func playSFX(inputString):
	var song : AudioStream = load("res://audio/sfx/" + inputString + ".ogg")
	$SFXPlayer.set_stream(song)
	$SFXPlayer.play()


func stopMusic():
	$MusicPlayer.stop()


func stopSFX():
	$SFXPlayer.stop()


# Return if a bus is muted
func isMusicMuted():
	return AudioServer.is_bus_mute(musicBus)


func isSFXMuted():
	return AudioServer.is_bus_mute(SFXBus)


# Toggle the mute states.
func toggleMusicMuted():
	AudioServer.set_bus_mute(musicBus, not isMusicMuted())


func toggleSFXMuted():
	AudioServer.set_bus_mute(SFXBus, not isSFXMuted())


# Set the mute states to a given input.
# True = muted, False = not muted (audible)
func setMusicMuted(boolInput):
	AudioServer.set_bus_mute(musicBus, boolInput)


func setSFXMuted(boolInput):
	AudioServer.set_bus_mute(SFXBus, boolInput)
