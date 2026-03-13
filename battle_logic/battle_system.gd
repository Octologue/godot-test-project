#region VARIABLES 

extends Node2D

var player_list_data = load("res://battle_logic/data/player_list.tres")
var battle_data = load("res://battle_logic/data/battle_test.tres")

var player_list : Array[Character]
var enemy_list : Array[Character]

var timeline : Array = []
var character_nodes : Dictionary = {}

@onready var players_node = $players
@onready var enemies_node = $enemies
@export var character_scene: PackedScene

@onready var timeline_UI = $UI/Timeline
@onready var options = $UI/Options
@onready var attack_button = $UI/Options/Attack
@onready var enemy_selection = $UI/EnemySelection
@export var enemy_button : PackedScene

var player_positions := [
	Vector2(150, 150),
	Vector2(150, 200),
	Vector2(150, 250),
	Vector2(150, 300)
]
var enemy_positions = battle_data.enemy_pos

enum BattleState {
	START,
	NEXT_TURN,
	PLAYER_TURN,
	ENEMY_TURN,
	ANIMATION,
	RESOLVE
}
var state : BattleState

func change_state(new_state):
	state = new_state
	match state:
		BattleState.START:
			print("START")
			start()
		BattleState.NEXT_TURN:
			print("NEXT_TURN")
			next_turn()
		BattleState.PLAYER_TURN:
			print("PLAYER_TURN")
			player_turn()
		BattleState.ENEMY_TURN:
			print("ENEMY_TURN")
			enemy_turn()
			
#endregion

func _ready():
	EventBus.character_died.connect(_on_character_died)
	EventBus.attacked_ennemy.connect(enemy_button_pressed)
	attack_button.pressed.connect(show_selection)
	
	change_state(BattleState.START)


func start():
	_variables_init()
	_spawn_characters(player_list,players_node)
	_spawn_characters(enemy_list,enemies_node)
	sort_and_display()
	change_state(BattleState.NEXT_TURN)

func next_turn():
	
	check_end_of_battle()
	
	timeline = timeline.filter(func(entry): return entry["character"].alive)
	var attacker = timeline[0]["character"]
	
	if attacker.is_player == true:
		change_state(BattleState.PLAYER_TURN)
	else:
		change_state(BattleState.ENEMY_TURN)

func player_turn():
	var attacker = timeline[0]["character"]
	show_options()
	
	await get_tree().create_timer(1).timeout
	

func enemy_turn():
	var attacker = timeline[0]["character"]
	var target = player_list.pick_random()
	await get_tree().create_timer(1).timeout
	attack(attacker, target)
	pop_out()
	change_state(BattleState.NEXT_TURN)

func check_end_of_battle():
	if enemy_list.is_empty():
		print("Tous les ennemis sont morts")
		get_tree().quit()
	if player_list.is_empty():
		print("Tous les joueurs sont morts")
		get_tree().quit()
	for i in player_list:
		print(i.title)
	for i in enemy_list:
		print(i.title)
		
#region INIT
func _variables_init():
	for player in player_list_data.character_list:
		player_list.append(player)
	for enemy in battle_data.enemy_list:
		var new_enemy = enemy.duplicate() 
		enemy_list.append(new_enemy)
		var button = enemy_button.instantiate() 
		button.character = new_enemy
		enemy_selection.add_child(button)
		
	if battle_data.is_enemy_order_random == true:
		enemy_list.shuffle()

func _spawn_characters(chara_list : Array,chara_node : Node2D):
	for child in chara_node.get_children():
		child.queue_free()
	var count = min(chara_list.size(), player_positions.size())
	for i in range(count):
		var chara_data = chara_list[i]
		var chara_scene = character_scene.instantiate()
		chara_node.add_child(chara_scene)
		
		if chara_data.is_player == true:
			chara_scene.position = player_positions[i]
		else :
			chara_scene.position = enemy_positions[i]
		chara_scene.setup(chara_data)
		character_nodes[chara_data] = chara_scene
	
func initialize_health_bars():
	return
		
	
#endregion
#region TIMELINE
func sort_and_display():
	sort_combined_queue()
	update_timeline_display()

func sort_combined_queue():
	var player_time_list = []
	for player in player_list:
		for i in player.queue:
			player_time_list.append({"character":player,"time":i})
	
	var enemy_time_list = []
	for enemy in enemy_list:
		for i in enemy.queue:
			enemy_time_list.append({"character":enemy,"time":i})
	
	timeline = player_time_list
	timeline.append_array(enemy_time_list)
	timeline.sort_custom(sort_by_time)
func sort_by_time(a,b):
	return a["time"] < b["time"]
	
func update_timeline_display():
	var index : int = 0
	for slot in timeline_UI.get_children():
		if index < timeline.size():
			slot.find_child("TextureRect").texture = timeline[index]["character"].sprite
			index += 1
		else:
			slot.find_child("TextureRect").texture = null 

func pop_out():
	if timeline[0]["character"].alive == false:
		return
	timeline[0]["character"].pop_out()
	sort_and_display()

#endregion
#region ATTACK

func attack(attacker, target):
	target.get_attacked(attacker)
	attack_anim(attacker,target)
	
func attack_anim(attacker,target):
	var attacker_node = character_nodes[attacker]
	var target_node = character_nodes[target]
	var shift = Vector2(10,0)
	if attacker_node.get_parent() and attacker_node.position.x > 0:
		shift = -shift
	await tween_movement(attacker_node,-shift)
	await tween_movement(attacker_node,shift)
func tween_movement(node,shift):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "position", node.position + shift, 0.2)
	await tween.finished

func _on_character_died(character):

	if character in player_list:
		player_list.erase(character)
	elif character in enemy_list:
		enemy_list.erase(character)

	timeline = timeline.filter(func(entry): return entry["character"] != character)
	character_nodes[character].queue_free()
	
	for button in enemy_selection.get_children():
		if button.character == character:
			button.queue_free()
			break  # Sortir de la boucle dès qu'on a trouvé le bon bouton


#endregion
#region USER INTERFACE

func show_options():
	options.show()
	

func show_selection():
	options.hide()
	enemy_selection.show()
	
func enemy_button_pressed(target):
	enemy_selection.hide()
	var attacker = timeline[0]["character"] 
	attack(attacker, target)
	pop_out()
	change_state(BattleState.NEXT_TURN)

func update_hp_bar():
	return

#endregion
