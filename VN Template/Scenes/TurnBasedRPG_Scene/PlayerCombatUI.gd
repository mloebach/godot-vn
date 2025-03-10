extends VBoxContainer

var sourceUnit : RPG_Character
@export var buttons : Array

signal get_order_from_buttons

func _ready():
	_on_character_begin_turn(sourceUnit)
	get_order_from_buttons.connect(sourceUnit._recieved_choice_from_action_menu)
	pass
	#get_node("/root/Battle_Scene").character_begin_turn.connect(_on_character_begin_turn)
	#get_node("/root/Battle_Scene").character_end_turn.connect(_on_character_end_turn)

func _on_character_begin_turn(character):
	if character.is_player:
		_display_combat_actions(character.combat_actions)
	pass
	
func _on_character_end_turn(character):
	queue_free()

func _tell_player_chosen_action(action):
	get_order_from_buttons.emit(action)
	
func _display_combat_actions(combat_actions):
	for i in len(buttons):
		#change to instantating button
		var button = get_node(buttons[i])
		#print(str("creating button-", i))
		if i < len(combat_actions):
			button.visible = true
			button.text = combat_actions[i].display_name
			button.combat_action = combat_actions[i]
			button.combat_action_casted.connect(_tell_player_chosen_action)
		else:
			button.visible = false
