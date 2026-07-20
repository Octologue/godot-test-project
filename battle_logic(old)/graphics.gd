extends Node2D

@onready var bs = $".."

@onready var character_button = preload("res://battle_system/UI/scenes/character_button.tscn")


#func _ready():
	#BattleEvent.hp_or_sp_changed.connect(update_bars)
	#BattleEvent.status_proc.connect(update_status)
	#BattleEvent.status_stop.connect(update_status)


	

#func chara_status_setup(chara: Character,group : VBoxContainer):
	#var status_ui = character_status_ui.instantiate()
	#status_ui.character = chara
	#status_ui.find_child("Icon").texture = chara.sprite 
	#status_ui.find_child("HPBar").character = chara
	#status_ui.find_child("SPBar").character = chara
	#status_ui.find_child("Title").text = chara.title
	#group.add_child(status_ui)
	#update_bars()
	

	
#func update_bars():
	#for child in $"../UI/PlayerStatus".get_children()+$"../UI/EnemyStatus".get_children():
		#child.find_child("HPBar").update_bar()
		#child.find_child("SPBar").update_bar()

#func update_status(effec,chara):
	#for child in $"../UI/PlayerStatus".get_children()+$"../UI/EnemyStatus".get_children():
		#var container = child.find_child("EffectContainer")
		#for panel in container.get_children():
			#panel.queue_free()
		#for effect in child.character.effects:
			#var new_panel = effect_panel.instantiate()
			#new_panel.find_child("TextureRect").texture = effect.icon 
			#container.add_child(new_panel)
		
func update_timeline_display():
	var index : int = 0
	for slot in $"../UI/Timeline".get_children():
		if index < bs.timeline.size():
			slot.find_child("TextureRect").texture = bs.timeline[index]["character"].sprite
			index += 1
		else:
			slot.find_child("TextureRect").texture = null 


#func _on_battle_log_button_pressed() -> void:
	#$"../UI/battleLogUI".show()
	#$"../UI/battleLogButton".hide()
	#$"../UI/battleLogUI/log".text = $"../battleLog".create_log_text()
	#$"../UI/Options".process_mode = Node.PROCESS_MODE_DISABLED
	#$"../UI/MoveSelection".process_mode = Node.PROCESS_MODE_DISABLED
	#$"../UI/AllySelection".process_mode = Node.PROCESS_MODE_DISABLED
	#$"../UI/EnemySelection".process_mode = Node.PROCESS_MODE_DISABLED
#
#func _on_back_log_pressed() -> void:
	#$"../UI/battleLogUI".hide()
	#$"../UI/battleLogButton".show()
	#$"../UI/Options".process_mode = Node.PROCESS_MODE_PAUSABLE
	#$"../UI/MoveSelection".process_mode = Node.PROCESS_MODE_PAUSABLE
	#$"../UI/AllySelection".process_mode = Node.PROCESS_MODE_PAUSABLE
	#$"../UI/EnemySelection".process_mode = Node.PROCESS_MODE_PAUSABLE
