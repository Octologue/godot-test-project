class_name BattleController
extends Node

enum BattleState {
	START,
	NEXT_TURN,
	PLAYER_TURN,
	ENEMY_TURN,
	ACTION,
	RESOLVE
}

@export var timeline : TimelineManager
@export var action_resolver : ActionResolver
@export var enemy_ai : EnemyAI
@export var ui : UIManager
@export var visuals : VisualsManager
@export var performance : PerformancesManager
@export var battle_log : BattleLogManager


var player_data : PlayerBattleData = load("res://battle_system/resources/player_battle_data.tres")
var battle_data : BattleData

var battle_state : BattleState

var ally_list : Array[Character]
var enemy_list : Array[Character]

var actor : Character
var current_move : Move
var targets : Array[Character]

func _ready() -> void:
	BattleEvent.move_button_pressed.connect(on_move_button_pressed)
	BattleEvent.target_selected.connect(on_target_selected)

func change_battle_state(new_state):
	battle_state = new_state
	match battle_state:
		BattleState.START : start()
		BattleState.NEXT_TURN : next_turn()
		BattleState.PLAYER_TURN : player_turn()
		BattleState.ENEMY_TURN : enemy_turn()
		BattleState.ACTION : action()

func initialize_battle_encounter(battle_data_OW:BattleData):
	battle_data = battle_data_OW
	change_battle_state(BattleState.START)

func start():
	init_allies()
	init_enemies()
	
	ui.duplicate_title_fix(enemy_list)
	timeline.initialize(ally_list, enemy_list)
	ui.refresh_timeline_ui(timeline.battle_timeline)
	
	change_battle_state(BattleState.NEXT_TURN)

func init_allies():
	for player in player_data.player_list:
		player.initialize()
		print (player.HP, player.hp)
		if player.alive:
			ally_list.append(player)
			visuals.player_sprite_init(player,player_data.player_positions[player])

func init_enemies():
	for enemy_data in battle_data.enemy_list:
		var enemy = enemy_data.enemy.duplicate(true)
		enemy.LVL = enemy_data.lvl
		enemy.wild = true
		enemy.initialize()
		enemy_list.append(enemy)
		visuals.enemy_sprite_init(enemy,enemy_data.position)

func next_turn():
	
	actor = timeline.get_actor()
	current_move = null
	targets.clear()
	
	if actor in ally_list:
		change_battle_state(BattleState.PLAYER_TURN)
	else:
		change_battle_state(BattleState.ENEMY_TURN)

func player_turn():
	ui.show_move_selection_menu(actor)

func on_move_button_pressed(move):
	current_move = move
	match current_move.move_range:
		current_move.MoveRange.SELF:
			targets = [actor]
			change_battle_state(BattleState.ACTION)
		current_move.MoveRange.ENEMY:
			ui.enable_target_seleciton(false)
		current_move.MoveRange.ALLY:
			ui.enable_target_seleciton(true)
		current_move.MoveRange.ENEMIES:
			targets = enemy_list.duplicate()
			change_battle_state(BattleState.ACTION)
		current_move.MoveRange.ALLIES:
			targets = ally_list.duplicate()
			change_battle_state(BattleState.ACTION)
		current_move.MoveRange.ALL:
			targets = ally_list + enemy_list
			change_battle_state(BattleState.ACTION)

func on_target_selected(target:Character):
	targets = [target]
	change_battle_state(BattleState.ACTION)

func enemy_turn():
	var enemy_act = enemy_ai.find_moves_and_targets(actor,enemy_list,ally_list)
	if enemy_act == null:
		print(actor, " CAN'T ACT")
		timeline.pop_actor()
		ui.refresh_timeline_ui(timeline.battle_timeline)
		change_battle_state(BattleState.NEXT_TURN)
	else:
		current_move = enemy_act["move"]
		targets = enemy_act["targets"]
		change_battle_state(BattleState.ACTION)

func action():
	#var action_result : BattleActionResult = action_resolver.resolve_action(actor,current_move,targets)
	
	timeline.on_move_used(actor,current_move)
	
	#if actor in ally_list:
		#performance.add_performance(action_result)

	await action_result_presentation()
	await get_tree().create_timer(1).timeout
	
	change_battle_state(BattleState.NEXT_TURN)
	
func action_result_presentation():
	ui.refresh_timeline_ui(timeline.battle_timeline)
