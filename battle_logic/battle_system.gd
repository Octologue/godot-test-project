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
@onready var move_selection = $UI/MoveSelection
@export var enemy_button : PackedScene
@export var move_button : PackedScene

var actor : Character
var move_used : Move
var target : Character

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
	ATTACK,
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
		BattleState.ATTACK:
			print("ATTACK")
			attack()
		BattleState.RESOLVE:
			print("RESOLVE")
			resolve()

#endregion

func _ready():
	randomize() #déplacer dans un script global plus tard
	EventBus.character_died.connect(_on_character_died)
	EventBus.attacked_ennemy.connect(enemy_button_pressed)
	EventBus.selected_move.connect(move_button_pressed)
	EventBus.speed_changed.connect(sort_and_display)
	attack_button.pressed.connect(show_move_selection) 
	
	change_state(BattleState.START)

func start():
	_variables_init()
	_spawn_characters(player_list,players_node)
	_spawn_characters(enemy_list,enemies_node)
	sort_and_display()
	
	change_state(BattleState.NEXT_TURN)

func next_turn():
	
	for chara in player_list + enemy_list:
		chara.effects_trigger()
	
	check_end_of_battle()
	timeline = timeline.filter(func(entry): return entry["character"].alive)
	
	actor = timeline[0]["character"]
	
	if actor.is_player == true:
		change_state(BattleState.PLAYER_TURN)
	else:
		change_state(BattleState.ENEMY_TURN)

func player_turn():
	show_options()
	
func enemy_button_pressed(target_selected):
	target = target_selected
	enemy_selection.hide()
	
	change_state(BattleState.ATTACK)

func enemy_turn():
	#appeler une fonction qui permet de caluler la meilleure cible possible (enemy_AI_compute ou un truc du genre)
	target = player_list.pick_random()
	move_used = actor.moveset.pick_random()
	
	change_state(BattleState.ATTACK)

func attack():
	var actor_node = character_nodes[actor]
	var target_node = character_nodes[target]
	var shift = Vector2(10,0)
	if actor_node.position.x < 325:
		shift = -shift
	await tween_movement(actor_node,-shift)
	#jouer les animations de move ici avec un await et en utilisant la variable qui store move
	#refresh l'affichage de la barre de vie ici
	attack_compute()
	pop_out()
	await tween_movement(actor_node,shift)
	
	change_state(BattleState.NEXT_TURN)

func tween_movement(node,shift):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "position", node.position + shift, 0.2)
	await tween.finished

func check_end_of_battle():
	if enemy_list.is_empty():
		print("Tous les ennemis sont morts")
		change_state(BattleState.RESOLVE)
	if player_list.is_empty():
		print("Tous les joueurs sont morts")
		change_state(BattleState.RESOLVE)

func resolve():
	print("fin du combat")
	await get_tree().create_timer(2.0).timeout
	get_tree().quit()
	
#region INIT

func _variables_init():
	for player in player_list_data.character_list:
		player_list.append(player)
	for enemy in battle_data.enemy_list:
		var new_enemy = enemy.duplicate() 
		enemy_list.append(new_enemy)
	duplicate_title_fix()
	for enemy in enemy_list:
		var button = enemy_button.instantiate() 
		button.character = enemy
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

func attack_compute():
	if move_used.sp_cost < actor.SP:
		actor.SP -= move_used.sp_cost
		target.get_attacked(actor,move_used)
		print (actor.title, " now has ",actor.SP," SP")
	else:
		print(actor.title," does not have enough SP : ",actor.SP,", cost : ",move_used.sp_cost)
	
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
			break  

func show_options():
	options.show()

func update_hp_bar():
	return

func show_move_selection():
	for child in move_selection.get_children():
		child.queue_free()
	for move in actor.moveset:
		var button = move_button.instantiate()
		button.move = move
		move_selection.add_child(button)
	move_selection.show()
	options.hide()

func move_button_pressed(move):
	move_used = move
	enemy_selection.show()
	move_selection.hide()

func duplicate_title_fix():
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
	
