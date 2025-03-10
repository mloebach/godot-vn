extends Button

var combat_action: CombatAction
signal combat_action_casted(combat_action)

func _on_pressed() -> void:
	#replace this in refactor
	#get_node("/root/Battle_Scene").cur_char.cast_combat_action(combat_action)
	combat_action_casted.emit(combat_action)
