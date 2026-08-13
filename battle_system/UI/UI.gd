extends CanvasLayer
class_name BattleUI

@onready var bs :BattleSystem = $".."
@onready var character_button = preload("res://battle_system/UI/scenes/character_button.tscn")
@onready var move_button = preload("res://battle_system/UI/scenes/move_button.tscn")
@onready var move_label = preload("res://battle_system/UI/scenes/move_info_label.tscn")

var effect_loop_timer = Timer.new()
var effect_dictionary : Dictionary[Character,Array]
var effect_index_dico : Dictionary[Character,int]

@onready var anim_menu = $battleMenu/animatedMenu

func _input(event : InputEvent) :
	if event.is_action_pressed("log"):
		toggle_log()
	if event.is_action_pressed("back (in battle)"):
		go_back()

#region INIT

func _ready():
	#BattleEvent.target_selected.connect(character_button_pressed)
	BattleEvent.selected_move.connect(move_button_pressed)
	BattleEvent.hp_or_sp_changed.connect(update_bars)
	BattleEvent.status_proc.connect(add_effect)
	BattleEvent.status_stop.connect(remove_effect)
	BattleEvent.target_selected.connect(on_target_selected)
	
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
	
func init_effect_UI():
	effect_dictionary.clear()
	effect_index_dico.clear()
	for c in bs.player_list:
		effect_dictionary[c]=[]
		effect_index_dico[c] = 0

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
		button.set_instance_shader_parameter("offset",Vector2(randi_range(-200,200),randi_range(-200,200)))
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

#endregion

#region MENU

func menu_appear():
	$battleMenu.position = (bs.player_data.player_positions[bs.actor] + Vector2(45,-50))
	anim_menu.play("appear")
	await $battleMenu/animatedMenu.animation_finished
	$battleMenu/actionButtons.show()

func _on_moves_button_pressed() :
	show_move_menu()

func show_move_menu():
	init_moves()
	$battleMenu/actionButtons.hide()
	
	$battleMenu/moveMenu.show()
	await get_tree().process_frame

	$battleMenu/moveMenu/menuBackground.size = Vector2(131,$battleMenu/moveMenu/menuBackground/buttonContainer.size.y+8)
	$battleMenu/moveMenu/menuBackground.position = Vector2(0,-$battleMenu/moveMenu/menuBackground.size.y)
	
	anim_menu.play("transition")

func menu_slide(menu,target_position):
	var tween = get_tree().create_tween()
	tween.tween_property(menu,"position",target_position,0.1)
	await tween.finished

func _on_animated_menu_frame_changed() -> void:
	if anim_menu.animation == "transition" and anim_menu.frame == 8 :
		menu_slide($battleMenu/moveMenu/menuBackground,Vector2(0,1))
	if anim_menu.animation == "transition_alt" and anim_menu.frame == 4 :
		menu_slide($battleMenu/moveMenu/menuBackground,Vector2(0,1))
	if anim_menu.animation == "disappear_alt" and anim_menu.frame == 1 :
		menu_slide($battleMenu/moveMenu/menuBackground,Vector2(0,-$battleMenu/moveMenu/menuBackground.size.y))
	if anim_menu.animation == "disappear_choice" and anim_menu.frame == 1 :
		menu_slide($battleMenu/moveMenu/menuBackground,Vector2(0,-$battleMenu/moveMenu/menuBackground.size.y))

func move_button_pressed(move):
	if move.move_range == move.Ranges.ALLY or move.move_range == move.Ranges.ENEMY:
		close_move_menu_with_target()
	else:
		close_move_menu()

func close_menu():
	$battleMenu/actionButtons.hide()
	if !anim_menu.is_playing():
		anim_menu.play("disappear")

func close_move_menu():
	anim_menu.play("disappear_alt")
	await anim_menu.animation_finished
	$battleMenu/moveMenu.hide()

func close_move_menu_with_target():
	anim_menu.play("disappear_choice")
	await anim_menu.animation_finished
	$battleMenu/moveMenu.hide()

func close_target_prompt():
	anim_menu.play("target_prompt_close")

func on_target_selected(character):
	close_target_prompt()

func go_back():
	if $battleMenu/moveMenu.visible:
		close_move_menu()
		await anim_menu.animation_finished
		menu_appear()
	if bs.selection_is_ally or bs.selection_is_enemy:
		$battleMenu/moveMenu.show()
		$battleMenu/moveMenu/menuBackground.size = Vector2(131,$battleMenu/moveMenu/menuBackground/buttonContainer.size.y+8)
		$battleMenu/moveMenu/menuBackground.position = Vector2(0,-$battleMenu/moveMenu/menuBackground.size.y)
		anim_menu.play("transition_alt")
		bs.selection_is_ally = false
		bs.selection_is_enemy = false

#endregion

#region UPDATE

func update_bars():
	for i in range(len(bs.player_list)):
		$statusOverview/characters.get_children()[i].find_child("hpBar").update_bar()
		$statusOverview/characters.get_children()[i].find_child("spBar").update_bar()

func update_timeline_display():
	var index : int = 0
	for slot in $timeline/HBoxContainer.get_children():
		if index < bs.timeline.size():
			slot.find_child("icon").texture = bs.timeline[index]["character"].full_icon
			index += 1
		else:
			slot.find_child("icon").texture = null 

func update_effect_display():
	for c in bs.player_list :
		if c.effects.is_empty():
			$statusOverview/characters.get_children()[bs.player_list.find(c)].find_child("iconEffect").texture = null
			continue
		var effects = effect_dictionary[c]
		var index = effect_index_dico[c]
		var effect = effects[index]

		$statusOverview/characters.get_children()[bs.player_list.find(c)].find_child("iconEffect").texture = effect.icon
		effect_index_dico[c]+=1
		if effect_index_dico[c] == effects.size():
			effect_index_dico[c] = 0

func add_effect(effect,chara):
	if chara is Monster:
		return
	effect_dictionary[chara].append(effect)
	effect_index_dico[chara] = chara.effects.size()-1
	update_effect_display()

func remove_effect(effect,chara):
	if chara is Monster:
		return
	effect_dictionary[chara].erase(effect)
	effect_index_dico[chara] = chara.effects.size()-1
	update_effect_display()

func on_character_died(chara : Character):
	effect_dictionary.erase(chara)
	effect_index_dico.erase(chara)
	$statusOverview/characters.get_children()[bs.player_list.find(chara)].find_child("iconEffect").texture = null
#endregion

#region INPUTS

func toggle_log():
	$battleLogUI.visible = !$battleLogUI.visible
	
#endregion

func init_key_selection():
	var index = 0
	if bs.selection_is_ally:
		for i in $"../players":
			i.index = index
			index += 1

func clear_UI():
	effect_loop_timer.queue_free()
	for chara in bs.player_list:
		effect_dictionary.erase(chara)
		effect_index_dico.erase(chara)
		$statusOverview/characters.get_children()[bs.player_list.find(chara)].find_child("iconEffect").texture = null
