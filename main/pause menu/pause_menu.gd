extends Control
@onready var player_data = preload("res://battle_logic/data/player_list.tres")
@onready var status_ui = preload("res://main/pause menu/status_ui.tscn")

var history := []
var current_menu = null

func open_menu(new_menu:Control):
	if current_menu != null:
		history.append(current_menu)
		current_menu.hide()
	current_menu = new_menu
	current_menu.show()

func _on_status_button_pressed():
	refresh_status()
	open_menu($Status)


func _on_back_pressed():
	go_back()

func go_back():
	if history.size() > 0:
		current_menu.hide()
		current_menu = history.pop_back()
		current_menu.show()

func refresh_status():
	for child in $Status.get_children():
		child.queue_free()
	for p in player_data.character_list:
		p.init()
		var ui = status_ui.instantiate()
		$Status.add_child(ui)
		ui.find_child("Title").text = p.title
		ui.find_child("Monster").text = p.monster.title
		ui.find_child("LVL").text = "LVL : " + str(p.LVL)
		ui.find_child("Icon").texture = p.sprite
		ui.find_child("Monster").text = p.monster.title
		ui.find_child("HPBar").max_value = p.HP
		ui.find_child("HPBar").value = p.hp
		ui.find_child("HPBar").find_child("Label").text = "hp : " + str(p.hp) + " / " + str(p.HP)
		ui.find_child("SPBar").max_value = p.SP
		ui.find_child("SPBar").value = p.sp
		ui.find_child("SPBar").find_child("Label").text = "sp : " + str(p.sp) + " / " + str(p.SP)
		ui.find_child("HP").text = "HP : " + str(p.HP)
		ui.find_child("SP").text = "SP : " + str(p.SP)
		ui.find_child("MATK").text = "MATK : " + str(p.MATK)
		ui.find_child("RATK").text = "RATK : " + str(p.RATK)
		ui.find_child("MDEF").text = "MDEF : " + str(p.MDEF)
		ui.find_child("RDEF").text = "RDEF : " + str(p.RDEF)
		ui.find_child("SPE").text = "SPE : " + str(p.SPE)
