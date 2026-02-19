extends Resource
class_name BattleData

@export var enemy_list : Array[Character]
@export var random_enemy_order : bool
@export var enemy_pos : Array[Vector2]:
	set (value):
		enemy_pos = value
		if random_enemy_order == true :
			enemy_pos.shuffle()

#add stuff like background, music or event later
