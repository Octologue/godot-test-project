extends Node2D

@onready var overworld = $Overworld
@onready var battle_scene_data = preload("res://battle_logic/scenes/battle_scene.tscn")
var battle_scene
@onready var camera_ow = $Overworld/PlayerOverworld/CameraOW
@onready var camera_battle = $battleScene/CameraBattle
@onready var player_data = preload("res://battle_logic/data/player_list.tres")

func _ready():
	add_to_group("main")
	init_player_stats()
	randomize() 

func initiate_battle_encounter(enemy_OW : CharacterBody2D):
	overworld.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.hide()
	enemy_OW.queue_free()
	battle_scene = battle_scene_data.instantiate()
	self.add_child(battle_scene)
	battle_scene.process_mode = Node.PROCESS_MODE_INHERIT
	battle_scene.battle_init(enemy_OW.battle_data)
	camera_ow.enabled = false
	
func stop_battle_encounter():
	battle_scene.queue_free()
	battle_scene.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.show()
	overworld.process_mode = Node.PROCESS_MODE_INHERIT
	camera_ow.enabled = true

func init_player_stats():
	for p in player_data.character_list:
		p.first_init_stats()
