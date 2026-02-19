extends Node2D

var player_list_data = load("res://battle_logic/data/player_list.tres")
var battle_data = load("res://battle_logic/data/battle_test.tres")

var player_list : Array[Character]
var enemy_list : Array[Character]

var timeline : Array = []
var character_nodes : Dictionary = {}
@onready var timeline_UI = $UI/Timeline
@onready var players_node = $players
@onready var enemies_node = $enemies
@export var character_scene: PackedScene

var player_positions := [
	Vector2(150, 150),
	Vector2(150, 200),
	Vector2(150, 250),
	Vector2(150, 300)
]
var enemy_positions = battle_data.enemy_pos

func _ready():
	_variables_init()
	_spawn_characters(player_list,players_node)
	_spawn_characters(enemy_list,enemies_node)
	debugging_prints()
	sort_and_display()
		
func _variables_init():
	for player in player_list_data.character_list:
		player_list.append(player)
	for enemy in battle_data.enemy_list:
		var new_enemy = enemy.duplicate()  
		enemy_list.append(new_enemy)
	if battle_data.is_enemy_order_random == true:
		enemy_list.shuffle()

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

func sort_combined_queue():
	var player_time_list = []
	for player in player_list:
		for i in player.queue:
			player_time_list.append({"character":player,"time":i})
	
	var enemy_time_list = []
	for enemy in enemy_list:
		for i in enemy.queue:
			enemy_time_list.append({"character":enemy,"time":i})
	
	timeline = player_time_list
	timeline.append_array(enemy_time_list)
	timeline.sort_custom(sort_by_time)
	
	
func sort_by_time(a,b):
	return a["time"] < b["time"]
	
func update_timeline_display():
	var index : int = 0
	for slot in timeline_UI.get_children():
		slot.find_child("TextureRect").texture = timeline[index]["character"].sprite
		index += 1
		
func sort_and_display():
	sort_combined_queue()
	update_timeline_display()

func debugging_prints():
	for i in player_list:
		print(i.title)
	for i in enemy_list:
		print(i.title)
	print("players =",players_node.get_children(),"enemies = ",enemies_node.get_children())
	print("character_nodes =", character_nodes)

func pop_out():
	timeline[0]["character"].pop_out()
	sort_and_display()
	
