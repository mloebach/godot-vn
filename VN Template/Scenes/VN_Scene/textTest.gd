extends Node

var storyText = ""
var textInScriptFile = []
var textToReadFrom = []
var testText = "testing this out"
var messageCount = 0

var scriptToLoad
var startingSection

var vnDatabase
var textPrintersNode
var isTextRevealing = false #is the text done revealing
var areWeWaiting = false #is the wait function currently active (surpressing input)
var canWeMoveOn = false #has the minimum message timer passed

signal command_casted(commandLine)
signal text_reveal_starting
signal reveal_text_early

signal move_to_title
signal move_to_gameplay

# Called when the node enters the scene tree for the first time.
func _ready():
	vnDatabase = $"VN Asset Database"
	textPrintersNode = $CanvasLayer/Control/TextPrinters
	#_create_script(scriptToLoad)
	#_declare_narrator("Narrator")
	#_read_text()
	#$Control/Panel/RichTextLabel.modulate = Color.GREEN
	#testText = "hi"
	#textPrintersNode.text_reveal_ending.connect(_text_reveal_over)
	#textPrintersNode.green_light_to_proceed_text.connect(_we_can_move_on) 

func _loadScript():
	#_create_script(scriptToLoad, startingSection)
	_jump_to_section(scriptToLoad, startingSection)
	_declare_narrator("Narrator")
	_read_text()
	#$Control/Panel/RichTextLabel.modulate = Color.GREEN
	testText = "hi"
	textPrintersNode.text_reveal_ending.connect(_text_reveal_over)
	textPrintersNode.green_light_to_proceed_text.connect(_we_can_move_on) 

func _input(event):
	if event.is_action_pressed("advance_text"):
		print("Advance button pressed.")
		if(!areWeWaiting):
			if(!isTextRevealing):
				_advance_text()
			elif(isTextRevealing && canWeMoveOn):
				reveal_text_early.emit()
				isTextRevealing = false
	pass
	
func _read_text():
	if(messageCount >= textToReadFrom.size()):
		print("Max messages recieved")
		return
	#var readLine = textToReadFrom[messageCount].split(":", 2)
	print("->" + textToReadFrom[messageCount])
	var readLine = textToReadFrom[messageCount]
	#replace line with customvariables
	readLine = readLine.format(vnDatabase.customVariables)
	
	#is line command or comment
	if readLine.length() > 0:
		match readLine[0]:
			"@":
				var commandLines = readLine.split(" ", true, 1)
				#wait has special logic
				match commandLines[0]:
					"@wait":
						areWeWaiting = true
						print("waiting for " + commandLines[1] + " secs")
						await get_tree().create_timer(float(commandLines[1])).timeout
						areWeWaiting = false
						messageCount += 1
						_read_text()
					"@goto":
						print("jumping in script to " + commandLines[1] + "!!")
						var jumpSection = commandLines[1].split(".", 2)
						var startingSection = ""
						if(jumpSection.size() > 1):
							startingSection = jumpSection[1]
						_jump_to_section(jumpSection[0], startingSection)
						_read_text()
					"@print":
						print("creating line through @print!" + commandLines[1])
						_speak_text_via_print(commandLines[1])
					"@title":
						print("retuning to title!")
						move_to_title.emit()
					"@gameplay":
						print("moving to gameplay!")
						move_to_gameplay.emit()
					_:
						print("idk if i know this command! - " + commandLines[0])
						messageCount += 1
						command_casted.emit(commandLines)
						_read_text()
						pass
			";":
				print("This is a comment! - " + readLine)
				messageCount += 1
				_read_text()
			"#":
				print("This is a label! - " + readLine)
				messageCount += 1
				_read_text()
			_:
				#this can't happen anymore
				#_speak_text(readLine)
				pass
	pass

func _speak_text_via_print(inputText):
	#ex: @print "we are gonna kill you" author:me
	var trueText = inputText.get_slice("\"", 1)
	var argumentText = inputText.get_slice("\"", 2)
	var argumentList = argumentText.split(" ", false)	
	print("arguments: " + argumentText)
	var authorName 
	
	for argument in argumentList:
		if argument.get_slice(":", 0) == "author":
			authorName = argument.get_slice(":", 1)
	
	#= argumentList.find("author:").get_slice(":", 0)
	
	if(argumentList.size() > 0):
		print("first argument: " + argumentList[0])
	
	_speak_text(trueText, authorName)
	pass

func _speak_text(textToSpeak, author = null):
	var line
	var narratorPanel = $CanvasLayer/Control/TextPrinters/MainPrinter/NarratorPanel
	var textBoxText =  $CanvasLayer/Control/TextPrinters/MainPrinter/MainTextPanel/MainText #pay attention once we begin to swap printers
	var readLine = textToSpeak.split(":", 2)
	if author == null: #no character is speaking
		narratorPanel.visible = false #hideNarratorBox
		#line = readLine[0].dedent()
		line = textToSpeak
	else: #character is speaking
		narratorPanel.visible = true #showNarratorBox
		_declare_narrator(author)
		#line = readLine[1].dedent()
		line = textToSpeak
	#textBoxText.set_visible_characters(0)
	textBoxText.text = line
	isTextRevealing = true
	canWeMoveOn = false
	text_reveal_starting.emit(line)
	print("signalling to start text reveal")
	#textBoxText.set_visible_characters(line.length())
	pass

func _text_reveal_over():
	isTextRevealing = false
	pass

func _we_can_move_on():
	canWeMoveOn = true
	pass

func _declare_narrator(line):
	var narratorText = "[center]" + line + "[/center]"
	$CanvasLayer/Control/TextPrinters/MainPrinter/NarratorPanel/NarratorText.text = narratorText
	pass

func _advance_text():
	if messageCount < (textInScriptFile.size()-1):
		messageCount += 1
	else:
		print("we outta messages")
	_read_text()
	pass

func _create_script(loadedScript):
	var script = FileAccess.open(loadedScript, FileAccess.READ)
	var content
	if !script.file_exists(loadedScript):
		content = "Story not found"
		return
	content = script.get_as_text().split("\n", false)
	
	textInScriptFile = _convert_to_print_commands(content)
	content = _load_section_of_script(textInScriptFile)
	return content

func _convert_to_print_commands(loadedScript):
	#
	#I don't get it! -> @print "I don't get it!"
	var content: Array[String]
	for line in loadedScript:
		match line[0]:
			"@":
				content.append(line)
			"#":
				content.append(line)
			";":
				#comments have no place, get rid of them here
				pass
			_:
				var printLine
				var spokenLine =  line.split(":")
				if spokenLine.size() > 1:
					printLine = "@print \"" + spokenLine[1].strip_edges() + "\"" + " author:" + spokenLine[0]
				else:
					printLine = "@print \"" + spokenLine[0] + "\""
				content.append(printLine)
	return content

func _load_section_of_script(content, entryLabel = null):
	if entryLabel == null:
		#empty label means nothing needs to be done
		textToReadFrom = content
		return content
	#find first instance of startingPoint
	print("found starting point at " + str(content.find("#"+entryLabel)))
	
	#load to stopping point aka @stop
	var startingPoint = 0
	var entryLabelPoint = content.find("#"+entryLabel)
	if entryLabelPoint != -1:
		startingPoint = entryLabelPoint

	var stopPoint = content.find("@stop", startingPoint)
	if stopPoint == -1:
		print("Stop not located.")
		stopPoint = content.size()
	print("making new story from " + str(startingPoint) + " to " + str(stopPoint))
	content = textInScriptFile.slice(startingPoint, stopPoint)

	#print(textToReadFrom[0])
	textToReadFrom = content
	return content

func _jump_to_section(sectionScript, sectionTitle):
	if(sectionScript != ""):
		#print("currentScript:" + VNData.storyScripts[sectionScript])
		print("currentScript:" + sectionScript)
		#vnDatabase.getStoryScript(sectionScript))
		#_create_script(vnDatabase.getStoryScript(sectionScript))
		#_create_script(VNData.storyScripts[sectionScript])
		_create_script(sectionScript)
	_load_section_of_script(textInScriptFile, sectionTitle)
	messageCount = 0
	pass
	


func _on_title_button_pressed() -> void:
	move_to_title.emit()
	pass # Replace with function body.
