extends Node2D

@onready var overworld = $Overworld
@onready var battle_scene_data = preload("res://battle_logic/scenes/battle_scene.tscn")
var battle_scene
@onready var camera_ow = $Overworld/PlayerOverworld/CameraOW
@onready var camera_battle = $battleScene/CameraBattle
@onready var player_data = preload("res://battle_logic/data/player_data.tres")

func _ready():
	add_to_group("main")
	init_player_stats()
	randomize() 
	
#func initiate_battle_encounter(enemy_OW : CharacterBody2D):
	#overworld.process_mode = Node.PROCESS_MODE_DISABLED
	#overworld.hide()
	#enemy_OW.queue_free()
	#battle_scene = battle_scene_data.instantiate()
	#self.add_child(battle_scene)
	#battle_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	#battle_scene.battle_init(enemy_OW.battle_data)
	#camera_ow.enabled = false

func initiate_battle_encounter(battle_data):
	overworld.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.hide()
	battle_scene = battle_scene_data.instantiate()
	self.add_child(battle_scene)
	battle_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	battle_scene.battle_init(battle_data)
	camera_ow.enabled = false

func stop_battle_encounter():
	battle_scene.queue_free()
	battle_scene.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.show()
	overworld.process_mode = Node.PROCESS_MODE_PAUSABLE
	camera_ow.enabled = true

func init_player_stats():
	var character_list : Array = player_data.player_list
	for i in range(character_list.size()):
		character_list[i].init()

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()
	
func toggle_pause():
	if get_node_or_null("/root/Main/battleScene") == null:
		var is_paused = get_tree().paused
		get_tree().paused = !is_paused
		$CanvasLayer/PauseMenu.visible = !is_paused
		$CanvasLayer/PauseMenu.open_menu($CanvasLayer/PauseMenu/Menu)
