extends Node2D

@onready var container1 = $CanvasLayer/VBoxContainer
@onready var container2 = $CanvasLayer/VBoxContainer2
var list : Array = ["one","two","three"]
@onready var attack = $CanvasLayer/VBoxContainer/attack
@onready var return_button = $CanvasLayer/VBoxContainer2/return
enum test {A,B,C}

var player_list_data = load("res://test_stuff/test_players.tres")
var battle_data = load("res://test_stuff/test_enemies.tres")
var player_list = player_list_data.character_list
var enemy_list = battle_data.enemy_list

var EnemyScript = load("res://battle_logic/enemy_ai.gd")
var enemy_script = EnemyScript.new()

func _ready():
	attack.pressed.connect(test_ai)
	return_button.pressed.connect(restore)
	player_list[0].init_stats()
	enemy_list[0].init_stats()
	print(player_list[0].mdef)

func test_ai():
	enemy_script.super_effective(enemy_list[0].moveset[0],player_list[0])
	enemy_script.kill_target(enemy_list[0],enemy_list[0].moveset[0],player_list[0])
	print(enemy_script.sp_cost(enemy_list[0],enemy_list[0].moveset[0]))

func restore():
	pass
