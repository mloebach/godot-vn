extends Node2D

signal move_to_vn
signal move_to_vn_scene

func _on_continue_button_pressed() -> void:
	#move_to_vn.emit(VNData.storyScripts["secondScene"])
	move_to_vn_scene.emit(VNData.storyScripts["secondScene"])
	#move_to_vn_scene.emit()
	pass # Replace with function body.


func _on_alt_scene_button_pressed() -> void:
	move_to_vn_scene.emit(VNData.storyScripts["secondScene"], "BattleLose")
	pass # Replace with function body.
