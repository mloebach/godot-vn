extends Node

var bgObject = load("res://Assets/UI Prefabs/Backgrounds/BackgroundImage.tscn")
var vnDatabase

signal change_BG_image(newBG)

# Called when the node enters the scene tree for the first time.
func _ready():
	vnDatabase = $"../VN Asset Database"
	$"../SceneLogic".create_background.connect(_background_command)
	#_change_bg_image("WeiRoom")
	pass # Replace with function body.

func _background_command(bgLineCommand):
	var bgCommands = bgLineCommand.split(" ")
	#interpret commands here
	
	if get_child_count() == 0:
		_create_background_object(bgCommands[0])
	else:
		change_BG_image.emit(_confirm_background(bgCommands[0]))
	pass
	

func _create_background_object(bgName):
	#create BG object
	
	var newBgObject = bgObject.instantiate()
	add_child(newBgObject)
	#change image of this bgObject
	change_BG_image.emit(_confirm_background(bgName))
	#newBgObject._change_bg_image(bgName)
	pass

func _confirm_background(bgName):
	var bgToCall = bgName
	if vnDatabase.getBackgroundDict().has(bgToCall):
		return vnDatabase.getBackgroundDict().get(bgToCall)
	else:
		print("Key does not exist in background dictionary: " + bgToCall)
	
	#$BackgroundImage.set_texture(backgroundImage)
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
