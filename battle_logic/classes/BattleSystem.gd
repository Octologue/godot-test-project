extends Node2D
class_name BattleSystem

#region VARIABLES and READY

# --- Data ---
@onready var character_scene = preload("res://battle_logic/scenes/character_scene.tscn")
@onready var move_button = preload("res://battle_logic/scenes/move_button.tscn")
@onready var character_button = preload("res://battle_logic/scenes/character_button.tscn")
@onready var character_status_ui = preload("res://battle_logic/scenes/character_status.tscn")
var player_list_data = load("res://battle_logic/data/player_list.tres")
var battle_data : BattleData

# --- nodes ---
@onready var players_node = $players
@onready var enemies_node = $enemies
@onready var timeline_UI = $UI/Timeline
@onready var options = $UI/Options
@onready var attack_button = $UI/Options/Attack
@onready var defend_button = $UI/Options/Defend
@onready var enemy_selection = $UI/EnemySelection
@onready var ally_selection = $UI/AllySelection
@onready var move_selection = $UI/MoveSelection


# --- Positions ---
var player_positions := [
	Vector2(150, 150),
	Vector2(150, 200),
	Vector2(150, 250),
	Vector2(150, 300)
]
var enemy_positions : Array

# --- Battle state enum ---
enum BattleState {
	START,
	NEXT_TURN,
	PLAYER_TURN,
	ENEMY_TURN,
	ACT,
	RESOLVE
}
var state : BattleState

# --- active variables ---
var player_list : Array[Character] 
var enemy_list : Array[Character] 
var timeline : Array 
var character_nodes : Dictionary 

var actor : Character
var move_used : Move
var targets : Array

var enemy_ai : EnemyAI = EnemyAI.new()

func change_state(new_state):
	state = new_state
	match state:
		BattleState.START: start()
		BattleState.NEXT_TURN: next_turn()
		BattleState.PLAYER_TURN: player_turn()
		BattleState.ENEMY_TURN: enemy_turn()
		BattleState.ACT: act()
		BattleState.RESOLVE: resolve()

func _ready():
	EventBus.character_died.connect(_on_character_died)
	EventBus.target_selected.connect(character_button_pressed)
	EventBus.selected_move.connect(move_button_pressed)
	EventBus.speed_changed.connect(sort_and_display)
	
	attack_button.pressed.connect(show_move_selection) 
	defend_button.pressed.connect(defend)

#endregion

#region START

func battle_init(battle_data_OW):
	battle_data = battle_data_OW
	enemy_positions = battle_data.enemy_pos
	change_state(BattleState.START)

func start():
	_variables_init()
	_spawn_characters(player_list,players_node)
	_spawn_characters(enemy_list,enemies_node)
	
	character_status_init(player_list,$UI/PlayerStatus)
	character_status_init(enemy_list,$UI/EnemyStatus)
	
	sort_and_display()
	
	change_state(BattleState.NEXT_TURN)

func _variables_init():
	
	for player in player_list_data.character_list:
		if player.alive:
			player_list.append(player)
	for player in player_list:
		if player.alive:
			var button = character_button.instantiate()
			button.character = player
			ally_selection.add_child(button)
		
	for enemy in battle_data.enemy_list:
		var new_enemy = enemy.duplicate() 
		enemy_list.append(new_enemy)
	
	for e in enemy_list:
		e.first_init_stats()
	for p in player_list:
		p.init_stats()
		if not p.alive:
			_on_character_died(p)
		
	duplicate_title_fix()
	
	if battle_data.is_enemy_order_random == true:
		enemy_list.shuffle()
		
	for enemy in enemy_list:
		var button = character_button.instantiate() 
		button.character = enemy
		enemy_selection.add_child(button)
		
func _spawn_characters(chara_list : Array,chara_node : Node2D):
	for child in chara_node.get_children():
		child.queue_free()
	
	for i in range(chara_list.size()):
		var chara_data = chara_list[i]
		var chara_scene = character_scene.instantiate()
		chara_node.add_child(chara_scene)
		
		if chara_data.is_player :
			chara_scene.position = player_positions[i]
		else :
			chara_scene.position = enemy_positions[i]
		chara_scene.setup(chara_data)
		character_nodes[chara_data] = chara_scene

func character_status_init(c_list : Array[Character],parent : VBoxContainer):
	for c in c_list :
		var status_ui = character_status_ui.instantiate()
		status_ui.find_child("Icon").texture = c.sprite 
		status_ui.find_child("HPBar").character = c
		status_ui.find_child("SPBar").character = c
		parent.add_child(status_ui)
	update_bars()

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
			
#endregion

#region NEXT TURN

func next_turn():
	if player_list.size()+enemy_list.size() == 0: #TODO emergency solution when everyone dies during a turn, to change
		change_state(BattleState.RESOLVE)
		return
	check_end_of_battle()
	for chara in player_list + enemy_list:
		chara.effects_trigger()
		chara.defending_check()
	
	timeline = timeline.filter(func(entry): return entry["character"].alive)
	
	targets.clear()
	actor = timeline[0]["character"]
	if actor.defending:
		actor.defending_check()
	
	if actor.is_player == true:
		change_state(BattleState.PLAYER_TURN)
	else:
		change_state(BattleState.ENEMY_TURN)
		
#endregion

#region PLAYER TURN

func player_turn():
	options.show()

func defend():
	options.hide()
	actor.defending = true
	pop_out()
	change_state(BattleState.NEXT_TURN)
	

func character_button_pressed(target_selected):
	targets.append(target_selected) 
	enemy_selection.hide()
	ally_selection.hide()
	
	change_state(BattleState.ACT)

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
	match move_used.move_range:
		
		move_used.Ranges.SELF:
			targets.append(actor)
			change_state(BattleState.ACT)
			
		move_used.Ranges.ENEMY:
			enemy_selection.show()
			
		move_used.Ranges.ENEMIES:
			for e in enemy_list:
				targets.append(e)
			change_state(BattleState.ACT)
			
		move_used.Ranges.ALLY:
			ally_selection.show()
			
		move_used.Ranges.ALLIES:
			for a in player_list:
				targets.append(a)
			change_state(BattleState.ACT)
			
		move_used.Ranges.R_ENEMY:
			targets.append(enemy_list.pick_random())
			change_state(BattleState.ACT)
			
		move_used.Ranges.ALL:
			for c in player_list+enemy_list:
				targets.append(c)
			change_state(BattleState.ACT)
		
	move_selection.hide()
	
#endregion

#region ENEMY TURN

func enemy_turn():
	var action = enemy_ai.find_moves_and_targets(actor,enemy_list,player_list)
	if player_list.is_empty():
		change_state(BattleState.RESOLVE)
	if action == null:
		if player_list.size() == 0: #TODO same, emergency solution for end of battle
			change_state(BattleState.RESOLVE)
			return
		print(actor, "has no possible actions")
		pop_out()
		change_state(BattleState.NEXT_TURN)
	else:
		move_used = action["move"]
		targets = action["targets"]
		change_state(BattleState.ACT)

#endregion

#region ACT and ATTACK

func act():
	var actor_node = character_nodes[actor]
	#var target_node = character_nodes[target]
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

func attack_compute():
	if move_used.sp_cost <= actor.sp:
		actor.sp -= move_used.sp_cost
		update_bars()
		for target in targets:
			if move_used.category == move_used.Categories.MELEE or move_used.category == move_used.Categories.RANGED:
				target.get_attacked(actor, move_used)
				update_bars()
			if move_used.category == move_used.Categories.HEAL:
				target.get_healed(move_used)
				update_bars()
			if move_used.category == move_used.Categories.STATUS:
				target.get_status(move_used)
		print (actor.title, " now has ",actor.sp," SP")
	else:
		print(actor.title," does not have enough SP : ",actor.sp,", cost : ",move_used.sp_cost)

func update_bars():
	for child in $UI/PlayerStatus.get_children()+$UI/EnemyStatus.get_children():
		child.find_child("HPBar").update_bar()
		child.find_child("SPBar").update_bar()
	

#endregion

#region RESOLVE and DIED

func _on_character_died(character):
	if character in player_list:
		player_list.erase(character)
	elif character in enemy_list:
		enemy_list.erase(character)

	timeline = timeline.filter(func(entry): return entry["character"] != character)
	character_nodes[character].queue_free()
	
	for button in enemy_selection.get_children()+ally_selection.get_children():
		if button.character == character:
			button.queue_free()
			break 
	
func check_end_of_battle():
	if enemy_list.is_empty():
		print("Tous les ennemis sont morts")
		change_state(BattleState.RESOLVE)
	if player_list.is_empty():
		print("Tous les joueurs sont morts")
		change_state(BattleState.RESOLVE)

func resolve():
	print("fin du combat")
	await get_tree().create_timer(1.0).timeout
	var main = get_tree().get_first_node_in_group("main")
	main.stop_battle_encounter()
	
	
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
	if player_list.size()+enemy_list.size() == 0: #TODO emergency solution blabblah
		change_state(BattleState.RESOLVE)
		return
	if timeline[0]["character"].alive == false:
		return
	timeline[0]["character"].pop_out()
	sort_and_display()

#endregion



	
