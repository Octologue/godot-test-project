extends Resource
class_name PlayerListData

@export var character_list : Array[Player]
@export var monster_list : Array[Monster]

@export var positions : Dictionary[Player,Vector2] = {}
