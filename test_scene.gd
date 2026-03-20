extends Node2D

@onready var container1 = $CanvasLayer/VBoxContainer
@onready var container2 = $CanvasLayer/VBoxContainer2
var list : Array = ["one","two","three"]
@onready var attack = $CanvasLayer/VBoxContainer/attack
@onready var return_button = $CanvasLayer/VBoxContainer2/return
enum test {A,B,C}
func _ready():
	attack.pressed.connect(ui_list_show)
	return_button.pressed.connect(ui_list_hide)

	

func ui_list_show():
	for i in list:
		var button = Button.new()
		button.text = i
		container2.add_child(button)
	container1.hide()
	container2.show()

func ui_list_hide():
	for child in container2.get_children():
		if child.text in list:
			child.queue_free()
	container1.show()
	container2.hide()
