extends Node2D

@onready var bs = $".."

func update_timeline_display():
	var index : int = 0
	for slot in $"../UI/Timeline".get_children():
		if index < bs.timeline.size():
			slot.find_child("TextureRect").texture = bs.timeline[index]["character"].sprite
			index += 1
		else:
			slot.find_child("TextureRect").texture = null 


func _on_battle_log_button_pressed() -> void:
	$"../UI/battleLogUI".show()
	$"../UI/battleLogButton".hide()
	$"../UI/battleLogUI/log".text = $"../battleLog".create_log_text()
	$"../UI/Options".process_mode = Node.PROCESS_MODE_DISABLED
	$"../UI/MoveSelection".process_mode = Node.PROCESS_MODE_DISABLED
	$"../UI/AllySelection".process_mode = Node.PROCESS_MODE_DISABLED
	$"../UI/EnemySelection".process_mode = Node.PROCESS_MODE_DISABLED

func _on_back_log_pressed() -> void:
	$"../UI/battleLogUI".hide()
	$"../UI/battleLogButton".show()
	$"../UI/Options".process_mode = Node.PROCESS_MODE_PAUSABLE
	$"../UI/MoveSelection".process_mode = Node.PROCESS_MODE_PAUSABLE
	$"../UI/AllySelection".process_mode = Node.PROCESS_MODE_PAUSABLE
	$"../UI/EnemySelection".process_mode = Node.PROCESS_MODE_PAUSABLE
