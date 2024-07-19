extends Node2D

var charObject = load("res://Assets/UI Prefabs/Characters/CharacterSprite.tscn")
var charaSprite_dict = {
	"Teto": "res://Assets/CharacterSprites/tetoTest.png",
}
signal change_char_image(newSprite)

var sceneLogic

# Called when the node enters the scene tree for the first time.
func _ready():
	sceneLogic = $"../SceneLogic"
	sceneLogic.change_character.connect(_character_command)
	sceneLogic.hide_all_chars.connect(_hiding_all_chars)
	sceneLogic.show_all_chars.connect(_showing_all_chars)
	pass # Replace with function body.

func _character_command(charLineCommands):
	var charCommands = charLineCommands.split(" ")
	#interpret commands here
	if get_child_count() == 0: #change this to "if specific character already exists" once database is in
		_create_character_object(charCommands[0])
	else:
		change_char_image.emit(_confirm_charaSprite(charCommands[0]))
	pass
	pass

func _create_character_object(charName):
	var newCharObject = charObject.instantiate()
	add_child(newCharObject)
	#change image of this bgObject
	change_char_image.emit(_confirm_charaSprite(charName))
	#newBgObject._change_bg_image(bgName)

func _confirm_charaSprite(charName):
	var charToCall = charName
	if charaSprite_dict.has(charToCall):
		return charaSprite_dict[charToCall]
	else:
		print("Key does not exist in sprite dictionary: " +charToCall)

func _hiding_all_chars():
	visible = false
func _showing_all_chars():
	visible = true
