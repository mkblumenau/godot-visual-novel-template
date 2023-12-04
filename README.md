# godot-visual-novel-template
This is a Godot project that can be used as a template for making visual novels. It's similar to Ren'Py, but it's not aiming to be a feature-complete recreation of it or any other engine.
Dialogue and events can be read in from text files or added as functions in the main scene script.

Features:
  Animated characters and backgrounds that can be edited visually
  Text box
    Can spell out text or output it all at once
    Shake
    BBCode tags and variables in text
    Fade all characters not speaking
  Menus for player input
    Player choice
    Text input
  Option to fade between scenes
  History menu
  Hoverable button included for creating imagemaps
  Sound
    Two channels: audio and SFX
    Player can mute and unmute channels from the in-game menu
  Text file-based scene/dialogue system similar to Ren'Py
    This doesn't have all possible features

Documentation
	Characters
		To add a character, add a new instance of character_template as a child of the Characters node.
		Make sure to give the character a name and a tag.
			The tag is like a short name that's used in the code to quickly reference the character.
			Tags must be unique, but names can be the same.
			Make sure the tag isn't an empty string (""). That's reserved for the narrator/non-character.
			Also check runSceneFromFile in MainScene and make sure that character tags don't coincide with any special tags from that.
		In its SpriteRenderer, make a new unique SpriteFrames, then add all the animations/images that you want to use to it.
	Background
		To add backgrounds, add them as animations to the Background object in SampleScene.
			This means that you can have animated backgrounds.
		To switch the background, you can just play the animation for the one you want.
		To switch the background and fade, call BGFade() with the animation you want.
			Follow it with await BGFadeDone.
  Audio
    Make sure that in the import settings for each audio file, it's set to loop or not loop depending on what you want.
	Text box
		Make sure to go into the inspector and attach the parent node of the characters to the Characters Container property.
		Also, in the signal connections, connect newText() to a function in MainScene that triggers setCharacterOpacities() in that script. This will make the function of making nonspeaking characters transparent work.
		I set the Z index to 1 to make sure it shows over the characters.
	Dialogue
		In dialogue files, write each line in this form:
			Character tag|What to say
		To write a line with no speaker (just the default narrator), just put the line and no character tag or |.
		If no character tag matches the line of dialogue, it will just use the default speaker.
		Avoid using brackets [] in dialogue, except to use BBCode tags.
		$name will be parsed as the variable under tag "name" in the dictionary called vars.
		Escape the dollar sign (\$) to prevent this from happening.
		Put a space in between the variable and any following punctuation.
		
		There are also other features that can be used in dialogue if you use runSceneFromFile to read the dialogue files. Read through runSceneFromFile in the code, or the sample dialogue file, to see what they all are.

    To call a dialogue file, use runSceneFromFile(). Put "await sceneFromFileDone" after that if you want to run any code after it.
	
	Make sure to include *.txt in the export settings for the project.

 If you rename the main scene node, make sure to update the choice and text input menus' scripts to refer to the new name of it.
