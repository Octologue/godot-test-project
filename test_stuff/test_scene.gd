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
	

func test_ai():
	print(enemy_list[0].moveset[0].type)
	print(player_list[0].weaknesses)
	enemy_script.super_effective(enemy_list[0].moveset[0],player_list[0])
	

func restore():
	pass
