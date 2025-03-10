extends Resource

class_name CombatAction

@export var display_name = "Action"
@export var base_value : int = 0
#@export var heal : int = 0

@export var targetting : AttackTargetting = AttackTargetting.Single_Enemy
@export var damageType : DamageType = DamageType.HP_Damage

enum AttackTargetting {
	Self,
	Single_Enemy,
	Single_Ally,
	All_Enemies,
	All_Allies,
	None
}

enum DamageType {
	HP_Damage,
	HP_Recover,
	HP_Drain
}
