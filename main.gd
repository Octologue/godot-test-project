extends Node2D

@onready var overworld = $Overworld
@onready var battle_scene = $battleScene
@onready var camera_ow = $Overworld/PlayerOverworld/CameraOW
@onready var camera_battle = $battleScene/CameraBattle


func _ready():
	add_to_group("main")
	randomize() 

func initiate_battle_encounter(enemy_OW : CharacterBody2D):
	overworld.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.hide()
	enemy_OW.queue_free()
	battle_scene.show()
	battle_scene.process_mode = Node.PROCESS_MODE_INHERIT
	battle_scene.battle_init(enemy_OW.battle_data)
	camera_battle.enabled = true
	camera_ow.enabled = false
	
	
func stop_battle_encounter():
	battle_scene.hide()
	battle_scene.process_mode = Node.PROCESS_MODE_DISABLED
	overworld.show()
	overworld.process_mode = Node.PROCESS_MODE_INHERIT
	camera_battle.enabled = false
	camera_ow.enabled = true
	
