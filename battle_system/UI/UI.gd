extends CanvasLayer
class_name BattleUI

@onready var bs :BattleSystem = $".."
@onready var character_button = preload("res://battle_system/UI/scenes/character_button.tscn")
@onready var move_button = preload("res://battle_system/UI/scenes/move_button.tscn")
@onready var move_label = preload("res://battle_system/UI/scenes/move_info_label.tscn")
#var effects_dict : Dictionary[Character,Array]
var effect_loop_timer = Timer.new()
var effect_dictionary : Dictionary
var effect_index : Dictionary


func _ready():
	#BattleEvent.target_selected.connect(character_button_pressed)
	BattleEvent.selected_move.connect(move_button_pressed)
	BattleEvent.hp_or_sp_changed.connect(update_bars)
	BattleEvent.status_proc.connect(add_effect)
	BattleEvent.status_stop.connect(remove_effect)
	
	effect_loop_timer.autostart = true
	effect_loop_timer.wait_time = 2.0
	self.add_child(effect_loop_timer)
	effect_loop_timer.timeout.connect(update_effect_display)

func init_character_status():
	for i in range(len(bs.player_list)):
		$statusOverview/characters.get_children()[i].find_child("iconCharacter").texture = bs.player_list[i].half_icon
		$statusOverview/characters.get_children()[i].find_child("iconMonster").texture = bs.player_list[i].monster.half_icon
		$statusOverview/characters.get_children()[i].find_child("hpBar").character = bs.player_list[i]
		$statusOverview/characters.get_children()[i].find_child("spBar").character = bs.player_list[i]
	update_bars()

func update_bars():
	for i in range(len(bs.player_list)):
		$statusOverview/characters.get_children()[i].find_child("hpBar").update_bar()
		$statusOverview/characters.get_children()[i].find_child("spBar").update_bar()
		print()

func update_effect_display():

	for c in bs.player_list :
		if c.effects.is_empty():
			$statusOverview/characters.get_children()[bs.player_list.find(c)].find_child("iconEffect").texture = null
			continue
		var effects = effect_dictionary[c]
		var index = effect_index[c]
		var effect = effects[index]
		
		$statusOverview/characters.get_children()[bs.player_list.find(c)].find_child("iconEffect").texture = effect.icon
		effect_index[c]+=1
		if effect_index[c] == effects.size():
			effect_index[c] = 0
	
func init_effect_UI():
	for c in bs.player_list:
		effect_dictionary[c]=[]
		effect_index[c] = null
		print("EFFECT DICO :",effect_dictionary)
		
func add_effect(effect,chara):
	print(chara.title,' ',effect.title)
	effect_dictionary[chara].append(effect)
	effect_index[chara] = chara.effects.size()-1
	update_effect_display()

func remove_effect(effect,chara):
	effect_dictionary[chara].erase(effect)
	effect_index[chara] = chara.effects.size()-1
	update_effect_display()
	
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
	await $battleMenu/animatedMenu.animation_finished
	$battleMenu/animatedMenu.play("disappear")
