class_name UIManager
extends Node

var timeline_panel : PackedScene = preload("res://battle_system/UI/timeline_panel.tscn")
var move_button : PackedScene = preload("res://battle_system/UI/move_button.tscn")
var character_button : PackedScene = preload("res://battle_system/UI/character_button.tscn")
@onready var timeline_container = $"../../CanvasLayer/Timeline"
@onready var move_selection = $"../../CanvasLayer/MoveSelection"
@onready var enemy_selection = $"../../CanvasLayer/EnemySelection2"

func _ready() -> void:
	BattleEvent.move_button_pressed.connect(on_move_button_pressed)
	BattleEvent.target_selected.connect(on_target_selected)

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
			slot.find_child("Icon").texture = null 

func show_battle_menu():
	pass

func refresh_move_selection(actor : Character):
	for child in move_selection.get_children():
		child.queue_free()
	for move in actor.moveset:
		var new_button = move_button.instantiate()
		new_button.move = move
		move_selection.add_child(new_button)

func refresh_enemy_selection(enemy_list):
	for child in enemy_selection.get_children():
		child.queue_free()
	for enemy in enemy_list:
		var new_button = character_button.instantiate()
		new_button.character = enemy
		enemy_selection.add_child(new_button)

func show_move_selection(actor:Character):
	refresh_move_selection(actor)
	move_selection.show()

func on_move_button_pressed(move):
	move_selection.hide()

func enable_enemy_selection(enemy_list):
	refresh_enemy_selection(enemy_list)
	enemy_selection.show()

func on_target_selected(character):
	enemy_selection.hide()

func duplicate_title_fix(enemy_list):
	var letter_list = ["a","b","c","d","e"]
	var title_total_count = {} 

	for enemy in enemy_list:
		var title = enemy.title
		title_total_count[title] = title_total_count.get(title, 0) + 1

	var title_seen_count = {} 
	for enemy in enemy_list:
		var title = enemy.title
		if title_total_count[title] > 1:
			var seen = title_seen_count.get(title, 0)
			enemy.title += " " + letter_list[seen]
			title_seen_count[title] = seen + 1
