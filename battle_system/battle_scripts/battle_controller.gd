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
@export var action : ActionResolver
@export var ui : UIManager
@export var visuals : VisualsManager

var player_data : PlayerBattleData = load("res://battle_system/resources/player_battle_data.tres")
var battle_data : BattleData

var battle_state : BattleState
var actor : Character
var current_move : Move
var targets : Array[Character]
var ally_list : Array[Character]
var enemy_list : Array[Character]

func change_battle_state(new_state):
	battle_state = new_state
	match battle_state:
		BattleState.START : start()

func initialize_battle_encounter(battle_data_OW:BattleData):
	battle_data = battle_data_OW
	change_battle_state(BattleState.START)

func start():
	init_allies()
	init_enemies()

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
		enemy_list.append(enemy)
		visuals.enemy_sprite_init(enemy,enemy_data.position)
		
