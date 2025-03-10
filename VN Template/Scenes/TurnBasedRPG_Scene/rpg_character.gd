extends Node2D
class_name RPG_Character

var unitInformation : BattleUnit
var unit_name : String
var is_player : bool
var cur_hp : int = 25
var max_hp : int = 25


@export var combat_actions : Array[CombatAction]
#@export var opponent : Node

@onready var health_bar : ProgressBar = $HealthBar
@onready var health_text : Label = $HealthBar/HealthText

#@onready var actionChoiceMenu = "res://Scenes/TurnBasedRPG_Scene/player_combat_actions_ui.tscn"

@export var visual : Texture2D
@export var flip_visual : bool

signal summon_choice_menu
signal recieve_action_choice
signal action_chosen(action)
signal change_player_unit_values(value)
signal change_enemy_unit_values(value)
signal character_is_dead(character)


func _ready():
	$Sprite.texture = visual
	$Sprite.flip_h = flip_visual
	#CHANGE THIS WHEN IMPLEMENTING PARTY PROPER EWWW
	#get_node("/root/Battle_Scene").character_begin_turn.connect(_on_character_begin_turn)
	health_bar.max_value = max_hp
	_update_health_bar()
	
func _read_battle_unit_resource():
	unit_name = unitInformation.unit_name
	is_player = unitInformation.is_player_unit
	max_hp = unitInformation.unit_max_hp
	cur_hp = max_hp
	combat_actions = unitInformation.combat_actions
	visual = unitInformation.visual
	flip_visual = unitInformation.flipVisual
	

func _take_damage(damage):
	cur_hp -= damage
	_update_health_bar()
	
	if cur_hp <= 0:
		#get_node("/root/Battle_Scene")._character_eliminated(self)
		character_is_dead.emit(self)
		_kill_character()
		
func _recover_health(amount):
	
	if(cur_hp + amount >= max_hp):
		cur_hp = max_hp
	else:
		cur_hp += amount
	
	_update_health_bar()
	

func _kill_character():
	queue_free()

func _update_health_bar():
	health_bar.value = cur_hp
	health_text.text = str(cur_hp, " / ", max_hp)
	
func _recieved_choice_from_action_menu(action):
	cast_combat_action(action)
	
func cast_combat_action(action):
	match action.damageType:
		CombatAction.DamageType.HP_Damage:
			#opponent._take_damage(action.base_value)
			#figure this out later, for now all damage is self inflicted
			#_take_damage(action.base_value)
			#print(str("targeting:", CombatAction.AttackTargetting))
			match (!is_player || action.targetting == CombatAction.AttackTargetting.Self):
				true:
					change_player_unit_values.emit(action.base_value)
				false:
					change_enemy_unit_values.emit(action.base_value)
		CombatAction.DamageType.HP_Recover:
			_recover_health(action.base_value)
	
	action_chosen.emit(action)
	#get_node("/root/Battle_Scene").cur_action = action	
	#get_node("/root/Battle_Scene")._end_current_turn()
	
func _on_character_begin_turn(character):
	if character == self and is_player == false:
		_decide_combat_action()
	else:
		_summon_choice_menu()
	pass

func _summon_choice_menu():
	#var newScene : Node  = load(actionChoiceMenu).instantiate()
	#add_child(newScene)
	summon_choice_menu.emit()

func _decide_combat_action():
	#print("deciding action...")
	var hp_percent = float(cur_hp) / float(max_hp)
	for i in combat_actions:
		#print("cycling through actions...")
		var action = i as CombatAction
		if i.damageType == CombatAction.DamageType.HP_Recover:
			if randf() > hp_percent + 0.2:
				#print("healing...!")
				cast_combat_action(action)
				return
			else:
				continue
		else:
			#print("attacking!")
			cast_combat_action(action)
			return
	pass
