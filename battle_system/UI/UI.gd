extends CanvasLayer
class_name BattleUI

@onready var bs = $".."
@onready var character_button = preload("res://battle_system/UI/scenes/character_button.tscn")
@onready var move_button = preload("res://battle_system/UI/scenes/move_button.tscn")
@onready var move_label = preload("res://battle_system/UI/scenes/move_info_label.tscn")
#var effects_dict : Dictionary[Character,Array]

func _ready():
	#BattleEvent.target_selected.connect(character_button_pressed)
	BattleEvent.selected_move.connect(move_button_pressed)
	BattleEvent.hp_or_sp_changed.connect(update_bars)

func init_character_status():
	for i in range(len(bs.player_list)):
		$statusOverview/characters.get_children()[i].find_child("iconCharacter").texture = bs.player_list[i].half_icon
		$statusOverview/characters.get_children()[i].find_child("iconMonster").texture = bs.player_list[i].monster.half_icon
		$statusOverview/characters.get_children()[i].find_child("hpBar").character = bs.player_list[i]
		$statusOverview/characters.get_children()[i].find_child("spBar").character = bs.player_list[i]
		
	update_bars()
	update_status_effects()

func update_bars():
	for i in range(len(bs.player_list)):
		$statusOverview/characters.get_children()[i].find_child("hpBar").update_bar()
		$statusOverview/characters.get_children()[i].find_child("spBar").update_bar()
		print()

func update_status_effects():
	pass
	#for i in range(len(bs.player_list)):
		#for e in bs.player_list[i].effects:
			#
		#$statusOverview/characters.get_children()[i].find_child("iconEffect").texture = bs.player_list[i].effect.icon

#func menu_appear():
	#$battleMenu.position = bs.player_data.player_positions[bs.actor] + Vector2(45,-50)
	#$battleMenu/actionButtons.position=Vector2(-$battleMenu/actionButtons.size.x,$battleMenu/actionButtons.position.y)
	#$battleMenu/actionButtons.show()
	#$battleMenu/animatedMenu.play("appear_alt")
	
func menu_appear():
	$battleMenu.position = bs.player_data.player_positions[bs.actor] + Vector2(45,-50)
	$battleMenu/animatedMenu.play("appear")
	await $battleMenu/animatedMenu.animation_finished
	$battleMenu/actionButtons.show()
	

func duplicate_title_fix():
	var letter_list = ["a","b","c","d","e"]
	var title_total_count = {} 

	for enemy in bs.enemy_list:
		var title = enemy.title
		title_total_count[title] = title_total_count.get(title, 0) + 1
		
	var title_seen_count = {} 
	for enemy in bs.enemy_list:
		var title = enemy.title
		if title_total_count[title] > 1:
			var seen = title_seen_count.get(title, 0)
			enemy.title += " " + letter_list[seen]
			title_seen_count[title] = seen + 1

func update_timeline_display():
	var index : int = 0
	for slot in $timeline/HBoxContainer.get_children():
		if index < bs.timeline.size():
			slot.find_child("icon").texture = bs.timeline[index]["character"].full_icon
			index += 1
		else:
			slot.find_child("icon").texture = null 

#TODO TEMPORARY
func chara_button_setup(chara: Character,group:VBoxContainer):
	var button = character_button.instantiate()
	button.character = chara
	group.add_child(button)

func _on_moves_button_pressed() :
	init_moves()
	show_move_menu()

func init_moves():
	
	var button_container = $battleMenu/moveMenu/menuBackground/buttonContainer
	var info_container = $battleMenu/moveMenu/menuBackground/infoContainer
	for child in button_container.get_children() + info_container.get_children():
		child.queue_free()
	
	for i in range(len(bs.actor.moveset)):
		var move : Move = bs.actor.moveset[i]
		var button : Button = move_button.instantiate()
		var label : Label = move_label.instantiate()
		var space : int = (16-len(move.title))/2+1
		var button_text = ""
		for s in range(space):
			button_text+=" "
		button_text += move.title
		button.text = button_text
		button.move = move
		button_container.add_child(button)
		match move.type:
			move.Types.FIERY,move.Types.LUSH,move.Types.TERRA,move.Types.NULL,move.Types.WIND:
				label.text += str(move.Types.keys()[move.type])
			move.Types.AQUEOUS:
				label.text += "AqUA"
			move.Types.FRIGID:
				label.text += "FRIGI"
			move.Types.ENERGY:
				label.text += "ENERG"
			move.Types.BALEFUL:
				label.text += "BALE"
			move.Types.RADIANT:
				label.text+= "RADIA"
			move.Types.MYSTIC:
				label.text += "MYST"
			move.Types.ETHEREAL:
				label.text += "ETHER"
		label.text+= "\n"+ "SP "+ str(move.sp_cost)
		info_container.add_child(label)

func show_move_menu():
	init_moves()
	$battleMenu/actionButtons.hide()
	
	$battleMenu/moveMenu.show()
	await get_tree().process_frame
	
	$battleMenu/moveMenu/menuBackground.size = Vector2(131,$battleMenu/moveMenu/menuBackground/buttonContainer.size.y+8)
	$battleMenu/moveMenu/menuBackground.position = Vector2(0,-$battleMenu/moveMenu/menuBackground.size.y)
	
	$battleMenu/animatedMenu.play("transition")
	
func menu_slide(menu,target_position):
	var tween = get_tree().create_tween()
	tween.tween_property(menu,"position",target_position,0.1)
	await tween.finished

func _on_animated_menu_frame_changed() -> void:
	if $battleMenu/animatedMenu.animation == "transition" and $battleMenu/animatedMenu.frame == 8 :
		menu_slide($battleMenu/moveMenu/menuBackground,Vector2(0,0))
	if $battleMenu/animatedMenu.animation == "disappear_alt" and $battleMenu/animatedMenu.frame == 1 :
		menu_slide($battleMenu/moveMenu/menuBackground,Vector2(0,-$battleMenu/moveMenu/menuBackground.size.y))

func close_move_menu():
	$battleMenu/animatedMenu.play("disappear_alt")
	await $battleMenu/animatedMenu.animation_finished
	$battleMenu/moveMenu.hide()

func move_button_pressed(move):
	close_move_menu()

func _on_defend_button_pressed() :
	$battleMenu/actionButtons.hide()
	$battleMenu/animatedMenu.play("disappear")
