extends Control

var pc: float
var mainText
var visibleChars
var advanceSymbol
var trueMainText
var mainNode
var sceneLogicNode
@export var shortPause: float = 0.05
@export var longPause: float = 0.8

signal text_reveal_ending
signal green_light_to_proceed_text

# Called when the node enters the scene tree for the first time.
func _ready():
	var mainNode = $"../../.."
	var sceneLogicNode = $"../../../SceneLogic"
	advanceSymbol = $MainPrinter/MainTextPanel/AdvanceArrow
	mainText = $MainPrinter/MainTextPanel/MainText
	mainNode.text_reveal_starting.connect(_set_text)
	mainNode.reveal_text_early.connect(_wrap_up_text)
	sceneLogicNode.hide_all_printers.connect(_hidingAllPrinters)
	sceneLogicNode.show_all_printers.connect(_showingAllPrinters)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _set_text(new_text: String):
	#text = new_text
	mainText.set_visible_ratio(0)
	advanceSymbol.visible = false
	visibleChars = 0
	$TextLoadTimer.wait_time = shortPause
	$TextLoadTimer.start()
	$InputGreenLightTimer.start()
	#yield(get_tree(), "idle_frame")
	#pc = 1.0 / mainText.text.length()
	print("no more bbCode: " + strip_bbcode((mainText.text)))
	trueMainText = strip_bbcode(mainText.text)
	print("Text reveal starting!")
	pass

func strip_bbcode(source:String) -> String:
	var regex = RegEx.new()
	regex.compile(("\\[.+?\\]"))
	return regex.sub(source, "", true)
	

func _hidingAllPrinters():
	#get_child(0).visible = false #only one printer should be active
	visible = false
	
func _showingAllPrinters():
	#get_child(0).visible = true #only one printer should be active
	visible = true


func _on_timer_timeout():
	visibleChars += 1
	#mainText.set_visible_characters(visibleChars)
	var textLoading = float(visibleChars) / float(trueMainText.length())
	#print("text loading progress: " + str(textLoading))
	mainText.set_visible_ratio(textLoading)
	#print("trueMainText[visibleChars-1]=" + trueMainText[visibleChars-1] + " at "+ str(visibleChars-1))
	if _is_this_char_sentence_ender(trueMainText, visibleChars-1): #stop a bit for punctuation
		#print("this is followed by " + trueMainText[visibleChars])
		if visibleChars < trueMainText.length() && !_is_this_char_sentence_ender(trueMainText, visibleChars): #if the period is NOT followed by another period
			$TextLoadTimer.wait_time = longPause
			#print("long pause time")
	else:
		$TextLoadTimer.wait_time = shortPause
	if visibleChars >= trueMainText.length():
		_wrap_up_text()
	pass # Replace with function body.

func _wrap_up_text():
	$TextLoadTimer.stop()
	advanceSymbol.visible = true
	#mainText.text += ("@") #in place of symbol
	mainText.set_visible_ratio(1)
	text_reveal_ending.emit()
	print("Text reveal done!")


func _on_input_green_light_timer_timeout():
	green_light_to_proceed_text.emit()
	pass # Replace with function body.
	
	
func _is_this_char_sentence_ender(line, point):
	return (line[point] == "." || line[point] == "?" ||  line[point] == "!")
