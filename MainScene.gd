extends Node2D
#@export var narratorColor: Color
@export var choiceMenuTemplate: PackedScene
@export var inputMenuTemplate: PackedScene
@export var sceneTextBox: Node
signal BGFadeDone
signal sceneFromFileDone

var vars = {"test": "Variable parsing works!",
			"y/n": "This will be overwritten"} # dictionary where variables go

""" This script runs the main gameplay scene.
It has a few UI functions, but also the actual gameplay functions
(such as characters speaking). """

# Called when the node enters the scene tree for the first time.
func _ready():
	makeInputMenu("What's your name?", "y/n")
	await $TextInputMenu.inputSent
	runSceneFromFile("sample_rich_dialogue")
	await sceneFromFileDone
	"""
	# This is just some stuff to test out the different systems in the game so far.
	$AudioSources.playMusic("Favorite")
	$Characters/Sylvie.fadeIn(0.5)
	# await statements stop the script from moving on until the relevant action is done.
	await $Characters/Sylvie/AnimationPlayer.animation_finished
	displayTextFromFile("res://dialogue/sample_dialogue.txt")
	sceneTextBox.shakeBox()
	await sceneTextBox.textFinished
	characterAnimate("s", "giggle")
	characterSetPosition("s", 0.3)
	$Characters/Sylvie.characterName = "Lord Pudi"
	characterSay("s", "Look at me now!")
	await sceneTextBox.textFinished
	characterHide("s")
	characterSay("", "Or not.")
	await sceneTextBox.textFinished
	"""
	
	"""
	characterShow("s")
	BGFade("mountain")
	await BGFadeDone
	characterSay("s", "up the mountain")
	await sceneTextBox.textFinished
	choiceMenu("What next?", [["Branch 1", branch1], ["Branch 2", branch2]])
	"""
	pass # Replace with function body.


func branch1():
	characterSetPosition("s", 0.9)
	characterSay("s", "You took branch 1.")
	await sceneTextBox.textFinished
	pass


func branch2():
	characterSetPosition("s", 0.9)
	characterSay("s", "You took branch 2.")
	await sceneTextBox.textFinished
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func displayTextFromFile(path):
	""" Takes a .txt file and reads it into the text box,
	breaking it off at every line break.
	Make sure to include an await for textFinished after calling this. """
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var fileAsArray = content.split("\n")
	#print(fileAsArray)
	
	var cleanFile = []
	for i in fileAsArray:
		cleanFile.append(i.trim_suffix("\r"))
		
	for i in cleanFile:
		var messageSplit = i.split("|")
		characterSay(messageSplit[0], messageSplit[1])


func runSceneFromFile(path):
	""" Takes a .txt file and reads it in as a sequence of events to perform. """
	var newPath = "res://dialogue/" + path + ".txt"
	var file = FileAccess.open(newPath, FileAccess.READ)
	var content = file.get_as_text()
	var fileAsArray = content.split("\n")
	#print(fileAsArray)
	
	var cleanFile = []
	for i in fileAsArray:
		cleanFile.append(i.trim_suffix("\r"))
		
	for i in cleanFile:
		# First, remove the spaces from the end of the line.
		# You can remove the arguments, which will also have it remove spaces
		# from the beginning of the line.
		var lineWithoutTrailingSpaces = i.strip_edges(false, true)
		var messageSplit = lineWithoutTrailingSpaces.split("|")
		""" Evaluate exactly what the message does here. """
		match messageSplit[0]:
			"#":
				""" Put #| at the start of a line to comment it out. """
				pass
			
			"sfx":
				if messageSplit[1] == "stop":
					$AudioSources.stopSFX()
				else:
					$AudioSources.playSFX(messageSplit[1])
			
			"music":
				if messageSplit[1] == "stop":
					$AudioSources.stopMusic()
				else:
					$AudioSources.playMusic(messageSplit[1])
			
			"pos":
				for c in $Characters.get_children():
					if c.characterTag == messageSplit[1]:
						c.setPositionFraction(float(messageSplit[2]))
			
			"fadein":
				for c in $Characters.get_children():
					if c.characterTag == messageSplit[1]:
						c.fadeIn(float(messageSplit[2]))
						await c.get_node("AnimationPlayer").animation_finished
			
			"fadeout":
				for c in $Characters.get_children():
					if c.characterTag == messageSplit[1]:
						c.fadeOut(float(messageSplit[2]))
						await c.get_node("AnimationPlayer").animation_finished
			
			"shake":
				sceneTextBox.shakeBox()
			
			"anim":
				for c in $Characters.get_children():
					if c.characterTag == messageSplit[1]:
						c.showAnimation(messageSplit[2])
			
			"show":
				characterShow(messageSplit[1])
			
			"hide":
				characterHide(messageSplit[1])
			
			"choice":
				# Creates a choice menu from the inputs.
				# Currently it's set up so that the only choices
				# are to just go to other dialogue files.
				var choiceMenuTitle = messageSplit[1]
				var choiceMenuContent = []
				# Go through all the inputs and add them as choices.
				var listPos = 2
				while listPos+ 1 < len(messageSplit):
					choiceMenuContent.append([messageSplit[listPos], messageSplit[listPos + 1]])
					listPos += 2
				print(choiceMenuContent)
				# Show the menu and wait for a choice.
				dialogueChoiceMenu(choiceMenuTitle, choiceMenuContent)
				await $ChoiceMenu.choiceMade
			
			"choicefunc":
				# Creates a choice menu from the inputs.
				# In this one, the choices go to function calls.
				var choiceMenuTitle = messageSplit[1]
				var choiceMenuContent = []
				# Go through all the inputs and add them as choices.
				var listPos = 2
				while listPos+ 1 < len(messageSplit):
					choiceMenuContent.append([messageSplit[listPos], messageSplit[listPos + 1]])
					listPos += 2
				print(choiceMenuContent)
				# Show the menu and wait for a choice.
				dialogueChoiceMenuFunctions(choiceMenuTitle, choiceMenuContent)
				await $ChoiceMenu.choiceMade
			
			"bgfade":
				BGFade(messageSplit[1])
				await BGFadeDone
			
			"setvar":
				""" Currently only sets to a string. """
				setVarsEntry(messageSplit[1], messageSplit[2])
			
			"jumpfile":
				# Jump to another file.
				runSceneFromFile(messageSplit[1])
			
			"jumpfunc":
				# Calls a function on this.
				var funcToCall = Callable(self, messageSplit[1])
				funcToCall.call()
			
			_:
				""" Default option: characterSay """
				"""
				if len(messageSplit) >= 2:
					characterSay(messageSplit[0], messageSplit[1])
				else:
					characterSay("", messageSplit[0])
				"""
				
				# Read in the character name and the message from the inputs,
				# depending on if there's a character name given.
				var characterName = ""
				var messageBeforeVars = ""
				if len(messageSplit) >= 2:
					characterName = messageSplit[0]
					messageBeforeVars = messageSplit[1]
				else:
					messageBeforeVars = messageSplit[0]
				
				""" Process the message for variables.
				If there's a word starting with $,
				it will be replaced with the entry in the dictionary vars
				with that tag.
				Escape it (\\$, but only one backslash) to avoid this. """
				var messageSplitByWords = messageBeforeVars.split(" ")
				
				var messageWithVars = ""
				
				for word in messageSplitByWords:
					if word.begins_with("\\$"):
						messageWithVars += "$" + word.trim_prefix("\\$")
					elif word.begins_with("$"):
						messageWithVars += str(vars[word.trim_prefix("$")])
					else:
						messageWithVars += word + " "
				
				"""
				for word in messageSplitByWords:
					print(word)
				"""
					
				messageWithVars.trim_suffix(" ")
				
				characterSay(characterName, messageWithVars)
				
				await sceneTextBox.textFinished
	
	emit_signal("sceneFromFileDone")
	pass


func characterSay(characterShort, textToSay):
	""" Say something as a character.
	If no character is found, this will use the default settings from the text box. """
	sceneTextBox.sayLine(characterShort, textToSay)


func characterAnimate(characterShort, animationName):
	""" Show an animation on a character using their character tag. """
	for c in $Characters.get_children():
		if c.characterTag == characterShort:
			c.showAnimation(animationName)


func characterSetPosition(characterShort, newPosition):
	""" Sets a character's position to a fraction of the screen horizontally. """
	for c in $Characters.get_children():
		if c.characterTag == characterShort:
			c.setPositionFraction(newPosition)


func characterShow(characterTag):
	for c in $Characters.get_children():
		if c.characterTag == characterTag:
			c.show()


func characterHide(characterTag):
	for c in $Characters.get_children():
		if c.characterTag == characterTag:
			c.hide()


func setCharacterOpacities(characterTag):
	""" Set the speaking characters to speaking opacity, 
	and set the nonspeaking characters as well.  
	This uses the names of the characters, not their tags. """
	for c in $Characters.get_children():
		if c.characterTag == characterTag:
			c.setSpeakingOpacity()
		else:
			c.setNotSpeakingOpacity()


func BGFade(newBGString):
	""" Fade to a new background. 
	Make sure to call await BGFadeDone after this. """
	$CanvasModulate/AnimationPlayer.play("fade1")
	await $CanvasModulate/AnimationPlayer.animation_finished
	$Background.play(newBGString)
	$CanvasModulate/AnimationPlayer.play("fade2")
	await $CanvasModulate/AnimationPlayer.animation_finished
	emit_signal("BGFadeDone")


func choiceMenu(menuName, choicesArray):
	""" Shows the choice menu. 
	Syntax: menuName is the label for the menu.  
	choicesArray is an array of arrays. 
	Each subarray is formatted as ["string for option name", functionToCallFromButton] """
	var newChoiceMenu = choiceMenuTemplate.instantiate()
	add_child(newChoiceMenu) # add to the tree before doing anything with it
	newChoiceMenu.setUpMenu(menuName, choicesArray)
	var screenWidth = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screenHeight = ProjectSettings.get_setting("display/window/size/viewport_height")
	newChoiceMenu.set_position(Vector2(screenWidth * 0.5, screenHeight * 0.5))


func dialogueChoiceMenu(menuName, choicesArray):
	var newChoiceMenu = choiceMenuTemplate.instantiate()
	add_child(newChoiceMenu) # add to the tree before doing anything with it
	newChoiceMenu.setUpMenuFromDialogue(menuName, choicesArray)
	var screenWidth = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screenHeight = ProjectSettings.get_setting("display/window/size/viewport_height")
	newChoiceMenu.set_position(Vector2(screenWidth * 0.5, screenHeight * 0.5))
	
	
func dialogueChoiceMenuFunctions(menuName, choicesArray):
	var newChoiceMenu = choiceMenuTemplate.instantiate()
	add_child(newChoiceMenu) # add to the tree before doing anything with it
	newChoiceMenu.setUpMenuDialogueFunctions(menuName, choicesArray)
	var screenWidth = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screenHeight = ProjectSettings.get_setting("display/window/size/viewport_height")
	newChoiceMenu.set_position(Vector2(screenWidth * 0.5, screenHeight * 0.5))


func makeInputMenu(title, keyToSet):
	# Show the input menu.
	var newInput = inputMenuTemplate.instantiate()
	add_child(newInput)
	newInput.setUpMenu(title, keyToSet)
	
	var screenWidth = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screenHeight = ProjectSettings.get_setting("display/window/size/viewport_height")
	newInput.set_position(Vector2(screenWidth * 0.5, screenHeight * 0.5))


func setVarsEntry(keyName, newValue):
	# Sets the value of a key in vars.
	if vars.has(keyName):
		vars[keyName] = newValue


func _on_text_box_new_text():
	setCharacterOpacities(sceneTextBox.characterSpeakingTag)


func _on_text_box_text_finished():
	$GUI/MenuButton.grab_focus()
	#print("textBoxGrab")
	# Once the text is finished, make all characters visible.
	# This can be removed; it's just for demonstration purposes.
	for c in $Characters.get_children():
		c.setSpeakingOpacity()


# Menu functions.
func _on_menu_button_pressed():
	$GUI/OptionsMenu.show()
	$GUI/OptionsMenu/VBoxContainer/MusicToggleCheckbox.button_pressed = not $AudioSources.isMusicMuted()
	$GUI/OptionsMenu/VBoxContainer/SFXToggleCheckbox.button_pressed = not $AudioSources.isSFXMuted()
	$GUI/OptionsMenu/VBoxContainer/CloseOptionsMenu.grab_focus()
	pass # Replace with function body.


func openMenu():
	$GUI/OptionsMenu.show()
	$GUI/OptionsMenu/VBoxContainer/MusicToggleCheckbox.button_pressed = not $AudioSources.isMusicMuted()
	$GUI/OptionsMenu/VBoxContainer/SFXToggleCheckbox.button_pressed = not $AudioSources.isSFXMuted()
	$GUI/OptionsMenu/VBoxContainer/CloseOptionsMenu.grab_focus()


func _on_music_toggle_checkbox_toggled(button_pressed):
	$AudioSources.setMusicMuted(not button_pressed)


func _on_sfx_toggle_checkbox_toggled(button_pressed):
	$AudioSources.setSFXMuted(not button_pressed)


func _on_close_options_menu_pressed():
	if sceneTextBox.is_visible():
		var focusButton = sceneTextBox.get_node("TextBoxButton")
		focusButton.grab_focus()
	else:
		$GUI/MenuButton.grab_focus()


func _on_return_to_main_button_pressed():
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_history_button_pressed():
	""" Set up the history menu. """
	$GUI/HistoryMenu.show()
	$GUI/HistoryMenu/VBoxContainer/CloseHistoryButton.grab_focus()
	var historyLabel = get_node("GUI/HistoryMenu/VBoxContainer/ScrollContainer/VBoxContainer/RichTextLabel")
	historyLabel.set_text("")
	for i in sceneTextBox.allPreviousLines:
		var characterTag = i[0]
		var characterName = ""
		var textLine = i[1]
		var characterColor = sceneTextBox.defaultColor
		for c in $Characters.get_children():
			if c.characterTag == characterTag:
				characterColor = c.characterColor
				characterName = c.characterName
				characterName += ": "
		
		historyLabel.push_color(characterColor)
		historyLabel.add_text(characterName)
		historyLabel.pop()
		# append_text makes sure that the BBCode tags are included.
		historyLabel.append_text(textLine + "\n\n")
	pass # Replace with function body.
