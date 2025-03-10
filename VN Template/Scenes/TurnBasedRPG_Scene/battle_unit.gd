extends Resource

class_name BattleUnit

@export var unit_name = "Unit"
@export var is_player_unit : bool = true
#@export var enemy_stats : Unit_Stats

@export var unit_max_hp = 25

@export var combat_actions : Array[CombatAction]

@export var visual : Texture2D
@export var flipVisual : bool
