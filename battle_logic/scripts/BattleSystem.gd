extends Node2D
class_name BattleSystem

#region VARIABLES and READY

# --- Data ---
@onready var character_scene = preload("res://battle_logic/scenes/character_scene.tscn")
@onready var move_button = preload("res://battle_logic/scenes/move_button.tscn")
@onready var character_button = preload("res://battle_logic/scenes/character_button.tscn")
@onready var character_status_ui = preload("res://battle_logic/scenes/character_status.tscn")
var player_data = load("res://battle_logic/data/player_data.tres")
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

var performances : Dictionary = {}

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
	BattleEvent.character_died.connect(_on_character_died)
	BattleEvent.target_selected.connect(character_button_pressed)
	BattleEvent.selected_move.connect(move_button_pressed)
	BattleEvent.speed_changed.connect(sort_and_display)
	BattleEvent.hp_or_sp_changed.connect(update_bars)
	attack_button.pressed.connect(show_move_selection) 
	defend_button.pressed.connect(defend)


#endregion

#region START

func battle_init(battle_data_OW):
	battle_data = battle_data_OW
	change_state(BattleState.START)

func start():
	for p in player_data.player_list:
		player_setup(p)
		performances[p] = {"damage": 0,"healing": 0,"status": 0,"enemies_killed":[]}
	for e in battle_data.enemy_list:
		enemy_setup(e)
	duplicate_title_fix()
	sort_and_display()
	
	change_state(BattleState.NEXT_TURN)

func player_setup(player : Player):
	if player.alive:
		player_list.append(player)
		player.init()
		
		var chara_node = character_scene.instantiate()
		$players.add_child(chara_node)
		chara_node.setup(player)
		chara_node.position = player_data.player_positions[player]
		character_nodes[player] = chara_node
		
		chara_button_setup(player,ally_selection)
		chara_status_setup(player,$UI/PlayerStatus)
		
	elif player.alive == false or player.hp <= 0:
		print(player.title, " already dead !")

func enemy_setup(enemy_data : EnemyBattleData):
	var enemy = enemy_data.enemy.duplicate(true)
	enemy.LVL = enemy_data.lvl
	enemy.wild = true
	enemy.init()
	enemy_list.append(enemy)
	
	var chara_node = character_scene.instantiate()
	$enemies.add_child(chara_node)
	chara_node.setup(enemy)
	chara_node.position = enemy_data.position
	character_nodes[enemy] = chara_node
	
	chara_button_setup(enemy,enemy_selection)
	chara_status_setup(enemy,$UI/EnemyStatus)

func chara_button_setup(chara: Character,group:VBoxContainer):
	var button = character_button.instantiate()
	button.character = chara
	group.add_child(button)

func chara_status_setup(chara: Character,group : VBoxContainer):
	var status_ui = character_status_ui.instantiate()
	status_ui.character = chara
	status_ui.find_child("Icon").texture = chara.sprite 
	status_ui.find_child("HPBar").character = chara
	status_ui.find_child("SPBar").character = chara
	status_ui.find_child("Title").text = chara.title
	group.add_child(status_ui)
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
	
	for chara in player_list + enemy_list:
		chara.effects_tick()
		chara.defending_check()
	
	$battleLog.show_current_text()
	BattleEvent.turn_end.emit()
	$battleLog.new_turn()

	if check_end_of_battle():
		return

	timeline = timeline.filter(func(entry): return entry["character"].alive)

	targets.clear()
	actor = timeline[0]["character"]
	if actor.defending:
		actor.defending_check()
		
	if actor is Player:
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
	actor.sp += 10
	update_bars()
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
		
		BattleEvent.enemy_cant_act.emit(actor)
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
	move_compute()
	if check_end_of_battle():
		return
	pop_out()
	await tween_movement(actor_node,shift)
	
	change_state(BattleState.NEXT_TURN)

func tween_movement(node,shift):
	var tween = get_tree().create_tween()
	tween.tween_property(node, "position", node.position + shift, 0.2)
	await tween.finished

func move_compute():
	if move_used.sp_cost <= actor.sp:
		BattleEvent.action_done.emit(actor,move_used,targets)
		actor.sp -= move_used.sp_cost
		update_bars()
		for target in targets:
			if move_used.category == move_used.Categories.MELEE or move_used.category == move_used.Categories.RANGED:
				var dmg = target.get_attacked(actor, move_used)
				if actor is Player:
					performances[actor]["damage"] += dmg
					if target.alive == false:
						performances[actor]["enemies_killed"].append(target)
				update_bars()
			if move_used.category == move_used.Categories.HEAL:
				var amount = target.get_healed(move_used)
				if actor is Player:
					performances[actor]["healing"] += amount
				update_bars()
			if move_used.category == move_used.Categories.STATUS:
				var applied = target.get_status(move_used,actor)
				if actor is Player:
					performances[actor]["status"] += applied
					if target is Monster and target.alive == false:
						performances[actor]["enemies_killed"].append(target)
		
	else:
		BattleEvent.not_enough_sp.emit(actor,move_used)

func update_bars():
	for child in $UI/PlayerStatus.get_children()+$UI/EnemyStatus.get_children():
		child.find_child("HPBar").update_bar()
		child.find_child("SPBar").update_bar()

func update_status():
	for child in $UI/PlayerStatus.get_children()+$UI/EnemyStatus.get_children():
		pass

#endregion

#region RESOLVE and DIED

func _on_character_died(character : Character):
	if character in player_list:
		player_list.erase(character)
	elif character in enemy_list:
		enemy_list.erase(character)
	character.effects.clear()

	timeline = timeline.filter(func(entry): return entry["character"] != character)
	
	character_nodes[character].queue_free()
	
	for button in enemy_selection.get_children()+ally_selection.get_children():
		if button.character == character:
			button.queue_free()
			break 
	BattleEvent.character_died_log.emit(character)
	
func check_end_of_battle():
	if enemy_list.size()+player_list.size()==0:
		print("all actors are dead")
		change_state(BattleState.RESOLVE)
		return true
	if enemy_list.is_empty():
		print("all enemies dead")
		change_state(BattleState.RESOLVE)
		return true
	if player_list.is_empty():
		print("all players dead")
		change_state(BattleState.RESOLVE)
		return true
	return false

func compute_xp_by_performances():
	for player in performances.keys():
		var stats = performances[player]

		var xp := 0

		xp += stats["damage"] * 0.5
		xp += stats["healing"] * 0.5
		xp += stats["status"] * 10
		
		for e in stats["enemies_killed"]:
			xp += e.xp_base * (float(e.LVL)/float(player.LVL))

		player.add_xp(xp)
	
func resolve():
	for p in player_data.player_list :
		p.last_hp = p.hp
		p.last_sp = p.sp
		if p.alive == false:
			p.last_hp = 0
			p.last_sp = 0
	print("fin du combat")
	#print(performances)
	compute_xp_by_performances()
	await get_tree().create_timer(1.0).timeout
	var main = get_tree().get_first_node_in_group("main")
	main.stop_battle_encounter()
	
	
#endregion

#region TIMELINE

func sort_and_display():
	sort_combined_queue()
	$graphics.update_timeline_display()

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

func pop_out():
	if timeline[0]["character"].alive == false:
		return
	timeline[0]["character"].pop_out()
	sort_and_display()

#endregion



	
