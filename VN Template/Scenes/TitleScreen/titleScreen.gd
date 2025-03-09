extends Node2D

@export var volume = 64
# Called when the node enters the scene tree for the first time.
signal move_to_vn

func _ready():
	pass # Replace with function body.


func _on_new_game_button_pressed():
	#var newScene = load(startingScript)
	#get_tree().change_scene_to_packed(ProjectScenes.vnScene)
	move_to_vn.emit()
	#start new game
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
	pass # Replace with function body.
