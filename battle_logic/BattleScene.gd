extends Node2D

var player_list_data = load("res://battle_logic/data/player_list.tres")
var player_list : Array

@onready var players_node = $players
@export var player_scene: PackedScene

var player_positions := [
	Vector2(200, 400),
	Vector2(260, 430),
	Vector2(320, 460),
	Vector2(380, 490)
]

func _ready():
	_battle_init()
	spawn_players()
	return
		
func _battle_init():
	print(player_list_data.character_list)
	for player in player_list_data.character_list:
		player_list.append(player)
	print(player_list)

func spawn_players():
	for child in players_node.get_children():
		child.queue_free()
	var count = min(player_list.size(),4)
	for i in range(count):
		var data = player_list[i]
		var player = player_scene.instantiate()
		players_node.add_child(player)
		player.position = player_positions[i]
		player.setup(data)
