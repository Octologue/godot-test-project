class_name EnemyAI
extends Node

var scores : Array[Dictionary]
@export var action_resolver : ActionResolver

func find_move_and_targets(actor : Character,enemy_list:Array[Character] ,player_list:Array[Character]):
	scores.clear()
	
	var chosen_move : Move
	var chosen_targets : Array[Character] = []
	compute_all_scores(actor,enemy_list,player_list)
	scores.sort_custom(sort_by_score)

	var total_score := 0
	var weights : Array[Dictionary]
	for s in scores: 
		var new_score := 0
		if s["score"] >= -40:
			new_score = int(pow(40 + s["score"],0.5))
			total_score += new_score
			s["score"] = new_score
			weights.append(s)
	if total_score == 0:
		return null

	var cumul := 0
	var r = randi()%total_score
	for action in weights: 
		cumul += action["score"]
		if r <= cumul:
			for t in  action["action"].targets:
				chosen_targets.append(t.target)
			chosen_move = action["action"].move
			break
	
	print_scores(actor,chosen_move)
	
	if total_score == 0:
		return null
	else:
		return {"targets":chosen_targets,"move":chosen_move}

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
	return {"action" : battle_action, "score": average(total_score) + move.ai_score}

func average(list):
	var sum := 0.0
	for i in list:
		sum += i
	return sum/list.size()

func sort_by_score(a,b):
	return a["score"] > b["score"]

func compute_attack_score(actor:Character,move:Move,target:BattleTarget,battle_action:BattleActionResult):
	var score : int = sp_cost_score(battle_action.enough_sp)\
			+ super_effective_score(target)\
			+ attack_category_score(move,target.target)\
			+ kill_score(target)\
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

func super_effective_score(target:BattleTarget):
	print(target.weakness)
	if target.weakness == target.Weakness.NEUTRAL:
		return 0
	elif target.weakness == target.Weakness.WEAK:
		return 50
	elif target.weakness == target.Weakness.RESIST:
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

func kill_score(target:BattleTarget):
	if target.damage>=target.target.hp:
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

func print_scores(actor,move):
	print("SCORES ",actor.title)
	for s in scores: 
		var target_names := []
		for t in s["action"].targets:
			target_names.append(t.target.title)
		print("Move:", s["action"].move.title,
		  "| Targets:", target_names,
		  "| Score:", s["score"])
	print("CHOSEN : ",move.title)
