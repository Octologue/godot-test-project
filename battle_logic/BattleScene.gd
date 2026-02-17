extends Node2D

var player_list_data = load("res://battle_logic/data/player_list.tres")
var battle_data = load("res://battle_logic/data/battle_test.tres")

var player_list : Array
var enemy_list : Array

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
	spawn_characters()
	return
		
func _variables_init():
	print(player_list_data.character_list)
	for player in player_list_data.character_list:
		player_list.append(player)
	for enemy in battle_data.enemy_list:
		enemy_list.append(enemy)
	print(player_list)
	print(enemy_positions)

func spawn_characters():
	for child in players_node.get_children():
		child.queue_free()
	for child in enemies_node.get_children():
		child.queue_free()
		
	var count = min(player_list.size(),4)
	for i in range(count):
		var data = player_list[i]
		var player = character_scene.instantiate()
		players_node.add_child(player)
		player.position = player_positions[i]
		player.setup(data)
		
	count = min(enemy_list.size(),4)
	for i in range(count):
		var data = enemy_list[i]
		var enemy = character_scene.instantiate()
		enemies_node.add_child(enemy)
		enemy.position = enemy_positions[i]
		enemy.setup(data)
