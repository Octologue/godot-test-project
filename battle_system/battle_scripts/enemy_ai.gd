class_name EnemyAI
extends Node

var scores : Array[Dictionary]
@export var action_resolver : ActionResolver

func find_move_and_targets(actor : Character,enemy_list:Array[Character] ,player_list:Array[Character]):
	var move_chosen : Move
	var targets_chosen : Array[Character]
	compute_all_scores(actor,enemy_list,player_list)
	scores.sort_custom(sort_by_score)
	
func get_scores_weights():
	var total := 0
	var weights : Array[Dictionary]
	for s in scores: 
		var new_score := 0
		if s["score"] >= -40:
			new_score = int(pow(40 + s["score"],0.5))
			total += new_score
			s["score"] = new_score
			weights.append(s)
	if total == 0:
		return null
	else:
		return weights


func compute_all_scores(actor : Character,enemy_list:Array[Character] ,player_list:Array[Character]):
	for move in actor.moveset:
		match move.move_range:
			move.MoveRange.ENEMY:
				for p in player_list:
					scores.append(compute_score(actor,move,[p]))
			move.MoveRange.ENEMIES:
				scores.append(compute_score(actor,move,player_list.duplicate()))
			move.MoveRange.ALLY:
				for e in enemy_list:
					scores.append(compute_score(actor,move,[e]))
			move.MoveRange.ALLIES:
				scores.append(compute_score(actor,move,enemy_list.duplicate()))
			move.MoveRange.SELF:
				scores.append(compute_score(actor,move,[actor]))
			move.MoveRange.ALL:
				pass

func compute_score(actor:Character,move:Move,targets:Array[Character]):
	var battle_action = action_resolver.create_action_result(actor,move,targets)
	var total_score := []
	for target in battle_action.targets:
		if move is AttackMove:
			total_score.append(compute_attack_score(actor,move,target,battle_action))
		if move is HealMove:
			total_score.append(compute_heal_score(move,target,battle_action))
		if move is StatusMove:
			total_score.append(compute_status_score(move,target,battle_action))
	return {"action" : battle_action, "score": average(total_score)}

func average(list):
	var sum := 0.0
	for i in list:
		sum += i
	return sum/list.size()

func sort_by_score(a,b):
	return a["score"] > b["score"]

func compute_attack_score(actor:Character,move:Move,target:BattleTarget,battle_action:BattleActionResult):
	var score : int = sp_cost_score(battle_action.enough_sp)\
			+ super_effective_score(target.weakness)\
			+ attack_category_score(move,target.target)\
			+ kill_score(target.can_kill)\
			+ boosted_score(actor)
	return score

func compute_heal_score(move:Move,target:Character,battle_action:BattleActionResult):
	var score : int = sp_cost_score(battle_action.enough_sp)\
			+ heal_score(move,target)
	return score

func compute_status_score(move:Move,target:Character,battle_action:BattleActionResult):
	var score : int = sp_cost_score(battle_action.enough_sp)\
			+ effect_score(target,move)
	return score
	
func sp_cost_score(is_enough:bool):
	if is_enough:
		return 0
	else:
		return -INF

func super_effective_score(weakness):
	if weakness == 0:
		return 0
	elif weakness == 1:
		return 50
	elif weakness == 2:
		return -20

func stab_score(stab:bool):
	if stab:
		return 20
	else:
		return 0

func effect_score(target,move):
	for e in target.effects:
		if e.title == move.effect.title:
			return -10 
	return 50

func kill_score(can_kill : bool):
	if can_kill:
		return 80
	else:
		return 0

func attack_category_score(move : AttackMove,target:Character):
	if move.category == move.Category.MELEE:
		if target.mdef<=target.rdef:
			return 0
		else : 
			return -20
	if move.category == move.Category.RANGED:
		if target.rdef<=target.mdef:
			return 0
		else : 
			return -20

func boosted_score(actor):
	if actor.matk > actor.MATK or actor.ratk > actor.RATK:
		return 20
	else:
		return 0

func heal_score(move,target):
	if target is Player or target.hp == target.HP:
		return -1000
	else:
		if target.hp >= target.HP/2:
			return -10
		else:
			return 40
