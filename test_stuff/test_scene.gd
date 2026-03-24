extends Node2D

@onready var container1 = $CanvasLayer/VBoxContainer
@onready var container2 = $CanvasLayer/VBoxContainer2
var list : Array = ["one","two","three"]
@onready var attack = $CanvasLayer/VBoxContainer/attack
@onready var return_button = $CanvasLayer/VBoxContainer2/return
enum test {A,B,C}

var enemy_ai : EnemyAI = EnemyAI.new()


@export var player_list : Array[Character]
@export var enemy_list : Array[Character]
@export var move : Move
@export var actor : Character

func _ready():
	for c in enemy_list+player_list:
		c.init_stats()
	enemy_ai.find_moves_and_targets(actor,enemy_list,player_list)
	attack.pressed.connect(test_ai)
	return_button.pressed.connect(restore)

func test_ai():
	pass

func restore():
	pass
