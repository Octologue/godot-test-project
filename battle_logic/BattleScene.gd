extends Node2D

var player_list_data = load("res://battle_logic/data/player_list.tres")
var battle_data = load("res://battle_logic/data/battle_test.tres")

var player_list : Array = []
var enemy_list : Array = []

var timeline : Array = []
var character_nodes : Dictionary = {}

@onready var players_node = $players
@onready var enemies_node = $enemies
@export var character_scene: PackedScene



var player_positions := [
	Vector2(200, 100),
	Vector2(200, 250),
	Vector2(200, 400),
	Vector2(200, 550)
]

var enemy_positions = battle_data.enemy_pos

func _ready():
	_variables_init()
	_spawn_characters(player_list,players_node)
	_spawn_characters(enemy_list,enemies_node)
	debugging_prints()
	
		
func _variables_init():
	for player in player_list_data.character_list:
		player_list.append(player)
	for enemy in battle_data.enemy_list:
		var new_enemy = enemy.duplicate()  
		enemy_list.append(new_enemy)

func _spawn_characters(chara_list : Array,chara_node : Node2D):
	for child in chara_node.get_children():
		child.queue_free()
	var count = min(chara_list.size(), player_positions.size())
	for i in range(count):
		var chara_data = chara_list[i]
		var chara_scene = character_scene.instantiate()
		chara_node.add_child(chara_scene)
		#pour positions, faire un check si player ou ennemi
		if chara_data.is_player == true:
			chara_scene.position = player_positions[i]
		else :
			chara_scene.position = enemy_positions[i]
		chara_scene.setup(chara_data)
		character_nodes[chara_data] = chara_scene


func debugging_prints():
	for i in player_list:
		print(i.title)
	for i in enemy_list:
		print(i.title)
	print("players =",players_node.get_children(),"enemies = ",enemies_node.get_children())
	print("character_nodes =", character_nodes)
