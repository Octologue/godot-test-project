extends Node2D

@onready var container1 = $CanvasLayer/VBoxContainer
@onready var container2 = $CanvasLayer/VBoxContainer2
var list : Array = ["one","two","three"]
@onready var attack = $CanvasLayer/VBoxContainer/attack
@onready var return_button = $CanvasLayer/VBoxContainer2/return
enum test {A,B,C}

@export var DEF : int = 10
var def : int = DEF

func _ready():
	attack.pressed.connect(change_def)
	return_button.pressed.connect(restore)
	print(def,DEF)

func change_def():
	def *= 1.5
	print (def, DEF)

func restore():
	def = DEF
	print(def, DEF)
