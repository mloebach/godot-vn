extends Node2D

signal create_background(bgName)
signal change_character(charName)
signal hide_all_printers()
signal show_all_printers()
signal hide_all_chars()
signal show_all_chars()

# Called when the node enters the scene tree for the first time.
func _ready():
	var mainScene = $".."
	mainScene.command_casted.connect(_on_command_recieved)
	pass # Replace with function body.

func _on_command_recieved(commandLine):
	var command = commandLine[0].erase(0,1)
	print("This is a command! - " + command)
	match command:
		"char": #introduce character or change them
			print("making character")
			change_character.emit(commandLine[1])
		"back": #create background or change
			print("making background!")
			create_background.emit(commandLine[1])
		"sfx":
			print("printing sound!")
			
		"print":
			print("printing line")
		"hidePrinter": #hide all visible printers
			hide_all_printers.emit()
		"showPrinter": #show all visible printers
			show_all_printers.emit()
		"hideChars":
			hide_all_chars.emit()
		"showChars":
			show_all_chars.emit()
		"title":
			print("returning to title!")
			get_tree().change_scene_to_file("res://Scenes/titleScreen.tscn")
	pass
