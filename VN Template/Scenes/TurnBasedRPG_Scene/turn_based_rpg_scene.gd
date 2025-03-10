extends Node2D

@export var player_char : BattleUnit
@export var enemy_char : BattleUnit


var playable_units : Array[RPG_Character]
var enemy_units : Array[RPG_Character]

var cur_char : RPG_Character
var cur_action: CombatAction
var turn_count : int = 0

var labelForNextVNScene : String

var encounterToLoad : Encounter

@onready var playerObject = "res://Scenes/TurnBasedRPG_Scene/rpg_character.tscn"
@onready var actionChoiceMenu = "res://Scenes/TurnBasedRPG_Scene/player_combat_actions_ui.tscn"

@onready var turnCheckerText = $Debug/TurnCheckerText
@onready var battleActionText = $Debug/BattleActionText
@onready var turnCountText = $Debug/TurnCounterText
@export var next_turn_delay : float = 1.0
@export var distance_in_opponent : float = 600.0

var battle_over : bool = false
signal character_begin_turn(character)
signal character_end_turn(character)
var turn_queue : Array[RPG_Character]

signal move_to_vn_scene

func _ready():
	#summon characters and enemy units, connect their signals
	#await get_tree().create_timer(0.5).timeout
	_summon_players()
	_summon_enemies()
	_begin_next_turn()
	pass
	
func _summon_players():
	var newPlayer = load(playerObject).instantiate()
	newPlayer.unitInformation = player_char
	newPlayer._read_battle_unit_resource()
	newPlayer.position.x -= distance_in_opponent
	playable_units.append(newPlayer)
	#get_node("/root/Battle_Scene").character_begin_turn.connect(_on_character_begin_turn)
	character_begin_turn.connect(newPlayer._on_character_begin_turn)
	newPlayer.action_chosen.connect(_player_action_chosen)
	newPlayer.character_is_dead.connect(_character_eliminated)
	newPlayer.summon_choice_menu.connect(_on_choice_menu_summoned)
	newPlayer.change_enemy_unit_values.connect(_hurt_enemy)
	newPlayer.change_player_unit_values.connect(_hurt_player)
	add_child(newPlayer)

func _summon_enemies():
	var newPlayer = load(playerObject).instantiate()
	newPlayer.unitInformation = enemy_char
	newPlayer._read_battle_unit_resource()
	newPlayer.position.x += distance_in_opponent
	enemy_units.append(newPlayer)
	character_begin_turn.connect(newPlayer._on_character_begin_turn)
	newPlayer.action_chosen.connect(_player_action_chosen)
	newPlayer.character_is_dead.connect(_character_eliminated)
	newPlayer.change_enemy_unit_values.connect(_hurt_enemy)
	newPlayer.change_player_unit_values.connect(_hurt_player)
	add_child(newPlayer)
	
func _on_choice_menu_summoned():
	var newMenu : Node = load(actionChoiceMenu).instantiate()
	character_end_turn.connect(newMenu._on_character_end_turn)
	newMenu.sourceUnit = cur_char
	add_child(newMenu)
	
func _load_encounter(encounter : Encounter):
	encounterToLoad = encounter
	
func _hurt_enemy(loss_value, target = 0):
	enemy_units[target]._take_damage(loss_value)
	print("you got this! damage: " + str(loss_value))
	
func _hurt_player(loss_value, target = 0):
	playable_units[target]._take_damage(loss_value)
	print("ouch! thats gotta hurt: " + str(loss_value))

func _begin_next_turn():
	#swaps each time
	#assumes only one on each side
	turn_count += 1
	turnCountText.text = str("Turns: ", turn_count)
	if cur_char == playable_units[0]:
		cur_char = enemy_units[0]
	elif cur_char == enemy_units[0]:
		cur_char =  playable_units[0]
	else:
		cur_char = playable_units[0]
		
	turnCheckerText.text = str("active turn: ", cur_char.unit_name)
	character_begin_turn.emit(cur_char)
	
func _player_action_chosen(action):
	cur_action = action
	_end_current_turn()
	
func _end_current_turn():
	battleActionText.text = str(cur_char.unit_name, " used ", cur_action.display_name, "!")
	character_end_turn.emit(cur_char)
	await get_tree().create_timer(next_turn_delay).timeout
	if battle_over == false:
		_begin_next_turn()
	else:
		move_to_vn_scene.emit(VNData.storyScripts["secondScene"], labelForNextVNScene)
	
func _character_eliminated(character):
	battle_over = true
	if character.is_player == true:
		print("you lose!")
		#move_to_vn_scene.emit(VNData.storyScripts["secondScene"], "BattleLose")
		labelForNextVNScene = "BattleLose"
		turnCheckerText.text = "GAME OVER!"
	else:
		print("you win!")
		#move_to_vn_scene.emit(VNData.storyScripts["secondScene"], "BattleWin")
		labelForNextVNScene = "BattleWin"
		turnCheckerText.text = "BATTLE FINISH!"
	pass
	
func _on_character_begin_turn(character):
	pass
	
