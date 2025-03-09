extends Node

var storyText = ""
var textInScriptFile = []
var textToReadFrom = []
var testText = "testing this out"
var messageCount = 0
@export_file("*.story") var startingScript
var vnDatabase
var textPrintersNode
var isTextRevealing = false #is the text done revealing
var areWeWaiting = false #is the wait function currently active (surpressing input)
var canWeMoveOn = false #has the minimum message timer passed

signal command_casted(commandLine)
signal text_reveal_starting
signal reveal_text_early

# Called when the node enters the scene tree for the first time.
func _ready():
	vnDatabase = $"VN Asset Database"
	textPrintersNode = $CanvasLayer/Control/TextPrinters
	_create_script(startingScript)
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
	if readLine.length() > 0 && readLine[0] == "@":
		var commandLines = readLine.split(" ", true, 1)
		#wait has special logic
		if(commandLines[0] == "@wait"):
			areWeWaiting = true
			print("waiting for " + commandLines[1] + " secs")
			await get_tree().create_timer(float(commandLines[1])).timeout
			areWeWaiting = false
			messageCount += 1
			_read_text()
		elif(commandLines[0] == "@goto"): #change syntax from location to script -> location
			print("jumping in script to " + commandLines[1] + "!!")
			var jumpSection = commandLines[1].split(".", 2)
			var startingSection = ""
			if(jumpSection.size() > 1):
				startingSection = jumpSection[1]
			_jump_to_section(jumpSection[0], startingSection)
			_read_text()
		elif(commandLines[0] == "@print"):
			print("creating line through @print!" + commandLines[1])
			_speak_text_via_print(commandLines[1])
		else:
			messageCount += 1
			command_casted.emit(commandLines)
			_read_text()
		#_parse_command(readLine[0].split(" ", 2))
		#_read_text()
	elif readLine.length() > 0 && readLine[0] == ";":
		print("This is a comment! - " + readLine)
		messageCount += 1
		_read_text()
	elif readLine.length() > 0 && readLine[0] == "#":
		print("This is a label! - " + readLine)
		messageCount += 1
		_read_text()
	#elif(readLine.length() >= 6 && readLine.substr(0,6) == "@print"):
	#	print("creating line through @print!")
	#	_speak_text(readLine)
	else:
		_speak_text(readLine)
	pass

func _speak_text_via_print(inputText):
	#ex: @print "we are gonna kill you" author:me
	var trueText = inputText.get_slice("\"", 1)
	var argumentText = inputText.get_slice("\"", 2)
	var argumentList = argumentText.split(" ", false)	
	print("arguments: " + argumentText)
	if(argumentList.size() > 0):
		print("first argument: " + argumentList[0])
	_speak_text(trueText)
	pass

func _speak_text(textToSpeak):
	var line
	var narratorPanel = $CanvasLayer/Control/TextPrinters/MainPrinter/NarratorPanel
	var textBoxText =  $CanvasLayer/Control/TextPrinters/MainPrinter/MainTextPanel/MainText #pay attention once we begin to swap printers
	var readLine = textToSpeak.split(":", 2)
	if readLine.size() == 1: #no character is speaking
		narratorPanel.visible = false #hideNarratorBox
		line = readLine[0].dedent()
	else: #character is speaking
		narratorPanel.visible = true #showNarratorBox
		_declare_narrator(readLine[0])
		line = readLine[1].dedent()
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
	textInScriptFile = content
	content = _load_section_of_script(textInScriptFile)
	return content

func _load_section_of_script(content, entryLabel = ""):
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

	textToReadFrom = content
	#print(textToReadFrom[0])
	return content

func _jump_to_section(sectionScript, sectionTitle):
	if(sectionScript != ""):
		print("currentScript:" + vnDatabase.getStoryScript(sectionScript))
		_create_script(vnDatabase.getStoryScript(sectionScript))
	_load_section_of_script(textInScriptFile, sectionTitle)
	messageCount = 0
	pass
	
