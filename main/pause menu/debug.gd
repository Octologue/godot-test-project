extends Control

var player_data = load("res://battle_system/resources/player_battle_data.tres")
var resource_list = load("res://battle_system/resources/battle_resource_list.tres")
var monster_list : Array[Monster]
@onready var mon_select_list = [$SAMcontainer/HBoxContainer2/SamMonsterOptions,
								$RUTHcontainer/HBoxContainer2/RuthMonsterOptions,
								$GABcontainer/HBoxContainer2/GabMonsterOptions,
								$MORcontainer/HBoxContainer2/MorMonsterOptions]
var resources_lists : Dictionary

func _ready():
	init_monster_selection()

#region character stats

func _on_sam_lvl_text_submitted(new_text: String) -> void:
	$SAMcontainer/HBoxContainer/SamLVL.text = str(int($SAMcontainer/HBoxContainer/SamLVL.text))
	player_data.player_list[0].LVL = int($SAMcontainer/HBoxContainer/SamLVL.text)

func _on_ruth_lvl_text_submitted(new_text: String) -> void:
	$RUTHcontainer/HBoxContainer/RuthLVL.text = str(int($RUTHcontainer/HBoxContainer/RuthLVL.text))
	player_data.player_list[1].LVL = int($RUTHcontainer/HBoxContainer/RuthLVL.text)
	
func _on_gab_lvl_text_submitted(new_text: String) -> void:
	$GABcontainer/HBoxContainer/GabLVL.text = str(int($GABcontainer/HBoxContainer/GabLVL.text))
	player_data.player_list[2].LVL = int($GABcontainer/HBoxContainer/GabLVL.text)
	
func _on_mor_lvl_text_submitted(new_text: String) -> void:
	$MORcontainer/HBoxContainer/MorLVL.text = str(int($MORcontainer/HBoxContainer/MorLVL.text))
	player_data.player_list[3].LVL = int($MORcontainer/HBoxContainer/MorLVL.text)
	

func init_monster_selection():
	for l in mon_select_list:
		var new_mon : Monster
		for mon in resource_list.monster_list:
			new_mon = mon.duplicate()
			new_mon.wild = false
			monster_list.append(new_mon)
		for m in monster_list:
			l.add_item(m.title)
		resources_lists[l] = monster_list.duplicate()
		monster_list.clear()
	
	for child in $EnemiesContainer.get_children():
		var new_mon : Monster
		for mon in resource_list.monster_list:
			new_mon = mon.duplicate()
			new_mon.wild = true
			monster_list.append(new_mon)
		for m in monster_list:
			child.find_child("Mon").add_item(m.title)
		resources_lists[child.find_child("Mon")] = monster_list.duplicate()
		monster_list.clear()
	
func _on_sam_monster_options_item_selected(index: int) :
	player_data.player_list[0].monster = resources_lists[$SAMcontainer/HBoxContainer2/SamMonsterOptions][index]

func _on_ruth_monster_options_item_selected(index: int) :
	player_data.player_list[1].monster = resources_lists[$RUTHcontainer/HBoxContainer2/RuthMonsterOptions][index]

func _on_gab_monster_options_item_selected(index: int) :
	player_data.player_list[2].monster = resources_lists[$GABcontainer/HBoxContainer2/GabMonsterOptions][index]

func _on_mor_monster_options_item_selected(index: int) :
	player_data.player_list[3].monster = resources_lists[$MORcontainer/HBoxContainer2/MorMonsterOptions][index]

func _on_heal_all_pressed():
	for p in player_data.player_list :
		p.alive = true
		if p.last_hp == null or p.last_sp == null:
			pass
		else:
			p.last_hp = p.HP
			p.last_sp = p.SP
#endregion

func create_new_battle_data():
	var debug_battle_data= BattleData.new()
	var enemy_positions: Array[Vector2] = [
	Vector2(400, 25),
	Vector2(350, 75),
	Vector2(400, 125),
	Vector2(350, 175),
	Vector2(400, 225)]
	
	for child in $EnemiesContainer.get_children():
		var new_enemy = EnemyData.new()
		new_enemy.enemy = resources_lists[child.find_child("Mon")][child.find_child("Mon").selected]
		new_enemy.lvl = int(child.find_child("Lvl").text)
		new_enemy.position = enemy_positions.pop_front()
		debug_battle_data.enemy_list.append(new_enemy)
	return debug_battle_data

func _on_start_battle_pressed() :
	find_parent("Main").toggle_pause()
	find_parent("Main").initiate_battle_encounter(create_new_battle_data())
	print(create_new_battle_data().enemy_list)
