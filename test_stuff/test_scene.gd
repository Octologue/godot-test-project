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
@export var actor : Character

@export var move : Move
@export var target : Character

func _ready():
	for c in enemy_list+player_list:
		c.init_stats()
	print("TEST SP" ,enemy_ai.sp_cost(actor,move))
	enemy_ai.find_moves_and_targets(actor,enemy_list,player_list)
