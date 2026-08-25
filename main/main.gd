extends Node2D

@onready var overworld = $Overworld
@onready var battle_scene_data = preload("res://battle_system/battle_system.tscn")
var battle_scene 
@onready var camera_ow = $Overworld/PlayerOverworld/CameraOW
@onready var camera_battle = $battleScene/CameraBattle
@onready var player_data = preload("res://battle_system/resources/player_battle_data.tres")
var in_battle := false

func _ready():
	add_to_group("main")
	init_player_stats()
	randomize() 

func initiate_battle_encounter(battle_data):
	overworld.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.hide()
	battle_scene = battle_scene_data.instantiate()
	self.add_child(battle_scene)
	battle_scene.process_mode = Node.PROCESS_MODE_PAUSABLE
	battle_scene.find_child("BattleController").initialize_battle_encounter(battle_data)
	in_battle = true
	camera_ow.enabled = false

func stop_battle_encounter():
	battle_scene.queue_free()
	battle_scene.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.show()
	overworld.process_mode = Node.PROCESS_MODE_PAUSABLE
	in_battle = false
	camera_ow.enabled = true

func init_player_stats():
	var character_list : Array = player_data.player_list
	for i in range(character_list.size()):
		character_list[i].initialize()

func _input(event):
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause():
	if in_battle == false:
		var is_paused = get_tree().paused
		get_tree().paused = !is_paused
		$CanvasLayer/PauseMenu.visible = !is_paused
		$CanvasLayer/PauseMenu.open_menu($CanvasLayer/PauseMenu/Menu)
