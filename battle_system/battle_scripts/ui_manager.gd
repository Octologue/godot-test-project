class_name UIManager
extends Node

var timeline_panel : PackedScene = preload("res://battle_system/UI/timeline_panel.tscn")
var move_button : PackedScene = preload("res://battle_system/UI/move_button.tscn")
@onready var timeline_container = $"../../CanvasLayer/Timeline"
@onready var move_selection = $"../../CanvasLayer/MoveSelection"

func _ready() -> void:
	BattleEvent.move_button_pressed.connect(on_move_button_pressed)

func player_ui_init(player):
	pass

func enemy_ui_init(enemy):
	pass

func refresh_timeline_ui(timeline):
	var index : int = 0
	for slot in timeline_container.get_children():
		if index < timeline.size():
			slot.find_child("Icon").texture = timeline[index]["character"].icon
			index += 1
		else:
			slot.find_child("icon").texture = null 

func show_battle_menu():
	pass

func refresh_move_selection_menu(actor : Character):
	for move in actor.moveset:
		var new_button = move_button.instantiate()
		new_button.move = move
		move_selection.add_child(new_button)

func show_move_selection_menu(actor:Character):
	refresh_move_selection_menu(actor)
	move_selection.show()

func on_move_button_pressed(move):
	move_selection.hide()

func enable_target_selection(is_target_ally:bool):
	pass
