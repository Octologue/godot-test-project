extends Node2D

var player_list_data = load("res://battle_logic/data/player_list.tres")
var players : Array
@export var players_node : Node2D

func _ready():
	_battle_init()
	return
		
	
func _battle_init():
	print(player_list_data.character_list)
	for player in player_list_data.character_list:
		players.append(player)
	print(players)
	players_node
