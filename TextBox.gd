extends Control
signal newText # Emitted when a new line of text is shown.
signal nextText # Emitted when the player clicks for the next line.
signal textFinished # Emitted when the text box is done with its input.

var allPreviousLines = [] # Used to track history.
var queue = [] # Used to include all incoming lines.
var queueRunning = false
var characterSpeakingTag = ""
# Used for making the spell out text option work.
var stopSpellingOutText = false
var textIsFinished = false
var openBracket = false

# In the inspector, make this the node with all characters as children.
@export var charactersContainer: Node
# Used for if there's no speaker.
@export var defaultName: String
@export var defaultColor: Color
# Set this to true if you want the text to be typed out not all at once.
@export var spellOutText: bool = false

"""
This script goes on the text box object.
Set the text box object to be hidden by default.

Children of this Control:
	Background- a ColorRect (not used in the script, just there for aesthetics)
	CharacterNameDisplay- a RichTextLabel
	TextDisplay- a RichTextLabel
		used to display the text
		Make sure "BBCode Enabled" is set to true on this
	TextBoxButton- a button covering the entire ColorRect
		Set it to transparent, but do not disable it
		Make sure that when the button is pressed, it emits nextText on this script
		
When you put this in a scene, make sure it's at position (0, 0).
Parent it to another control if you want to change its location.
That way, the shake effect will work properly.
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# Functions about displaying text.
func sayLine(characterTag, textToSay):
	queue.append([characterTag, textToSay])
	if not queueRunning:
		runQueue()


func sayLineNoSpeaker(textToSay):
	# Say just one line, with no speaker.
	queue.append(["", textToSay])
	if not queueRunning:
		runQueue()


func runQueue():
	""" Displays all lines of text from the queue.
	This is sort of a loop, but it's not formatted as one 
	so the await will work. """
	show()
	queueRunning = true
	#print(queue)
	$TextBoxButton.grab_focus()
	displayText(queue[0])
	characterSpeakingTag = queue[0][0]
	emit_signal("newText")
	allPreviousLines.append(queue[0])
	queue.remove_at(0)
	await nextText
	if queue.size() > 0:
		runQueue()
	else:
		queueRunning = false
		hide()
		#print("endOfQueue")
		emit_signal("textFinished")


func displayText(arrayInput):
	""" Displays text on the text box. 
	Format: [characterTag, "text"] """

	#$Container/CharacterNameDisplay.pop()
	var characterName = defaultName
	var characterColor = defaultColor
	var textToDisplay = ""
	
	# Set text for the character name, including text tags.
	for c in charactersContainer.get_children():
		if c.characterTag == arrayInput[0]:
			characterName = c.characterName
			characterColor = c.characterColor
			if c.textBold:
				textToDisplay += "[b]"
			if c.textItalic:
				textToDisplay += "[i]"
			if c.customTextFontUsed:
				textToDisplay += "[font={" + c.customTextFontPath + "}]"
				
	
	$Container/CharacterNameDisplay.set_text("")
	$Container/CharacterNameDisplay.clear() #Clears all previous tags added on top of the text.
	$Container/CharacterNameDisplay.push_color(characterColor)
	$Container/CharacterNameDisplay.add_text(characterName)
	
	# Set text for the body of the text box.
	textToDisplay += arrayInput[1]
	if spellOutText:
		""" 
		Spells out the text one character at a time.
		Adjust the time on SpellOutTextTimer to adjust the speed that this goes.
		"""
		$SpellOutTextTimer.start()
		var textOutput = ""
		# textIsFinished is used to tell the text button whether it should move on when clicked,
		# or just skip to the end of this line of dialogue.
		textIsFinished = false
		for i in textToDisplay:
			if stopSpellingOutText:
				# Skip to the end of the line if this variable was set from the button.
				stopSpellingOutText = false
				break
			# openBracket is used so that it doesn't wait between each character of the bracket tag.
			# That way, it will seamlessly handle italics.
			# Avoid putting brackets in your dialogue to avoid accidentally triggering this.
			if i == "[":
				openBracket = true
			if openBracket and i == "]":
				openBracket = false
			#print(i)
			textOutput += i
			$Container/TextDisplay.set_text(textOutput)
			if not openBracket:
				await $SpellOutTextTimer.timeout
		
		# This happens after it's looped through all the characters, or when the loop is broken.
		textIsFinished = true
		$SpellOutTextTimer.stop()
		$Container/TextDisplay.set_text(textToDisplay)
	else:
		# Just set the text all at once if spellOutText isn't on.
		$Container/TextDisplay.set_text(textToDisplay)


func _on_text_box_button_pressed():
	if spellOutText and not textIsFinished:
		stopSpellingOutText = true
		textIsFinished = true
	else:
		emit_signal("nextText")


func shakeBox():
	""" Plays an animation to shake the text box. """
	$AnimationPlayer.play("shake")
