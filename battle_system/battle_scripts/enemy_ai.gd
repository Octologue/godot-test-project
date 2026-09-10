class_name EnemyAI
extends Node

var scores : Array[Dictionary]

func find_moves_and_targets(actor : Character,enemy_list:Array[Character] ,player_list:Array[Character]):
	var choosen_targets : Array
	var choosen_move : Move
	
	compute_total_scores(actor,enemy_list,player_list)
	scores.sort_custom(sort_by_score)
	for s in scores: #print
		var target_names := []
		for t in s["targets"]:
			target_names.append(t.title)
		#print("Move:", s["move"].title,
		  #"| Targets:", target_names,
		  #"| Score:", s["score"])
	
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
	
	var cumul := 0
	
	var r = randi()%total
	for action in weights: 
		cumul += action["score"]
		if r <= cumul:
			choosen_targets = action["targets"]
			choosen_move = action["move"]
			break
	
	scores.clear()
	cumul = 0
	#print(actor.title," choosen move : ", choosen_move.title," and targets : ",choosen_targets.map(func(i):return i.title))
	return {"targets":choosen_targets,"move":choosen_move}

func sort_by_score(a,b):
	return a["score"] > b["score"]


#region SCORE COMPUTING

func compute_total_scores(actor,enemy_list,player_list):
	for move in actor.moveset:
		match move.move_range:
			move.MoveRange.ENEMY:
				for p in player_list:
					scores.append({"targets":[p],"move":move,"score":compute_score(actor,move,[p])})
			move.MoveRange.ENEMIES:
				scores.append({"targets":player_list.duplicate(),"move":move,"score":compute_score(actor,move,player_list)})
			move.MoveRange.ALLY:
				for e in enemy_list:
					scores.append({"targets":[e],"move":move,"score":compute_score(actor,move,[e])})
			move.MoveRange.ALLIES:
				scores.append({"targets":enemy_list.duplicate(),"move":move,"score":compute_score(actor,move,enemy_list)})
			move.MoveRange.SELF:
				scores.append({"targets":[actor],"move":move,"score":compute_score(actor,move,[actor])})
			move.MoveRange.ALL:
				scores.append({"targets":enemy_list.duplicate()+player_list.duplicate(),"move":move,"score":compute_range_all(actor,move,enemy_list+player_list)})

func compute_score(actor : Character,move : Move, targets : Array[Character]) :
#compute for single target or self moves
	var total_scores :Array[int]
	for target in targets:
		var score : int
		if move is AttackMove:
			score = sp_cost(actor,move)\
			+ super_effective(move,target)\
			+ attack_category(move,target)\
			+ kill_target(actor,move,target)\
			+ boosted(actor)
		if move is HealMove:
			score = sp_cost(actor,move) + heal(move,target)
		if move is StatusMove:
			score = sp_cost(actor,move) + status(move,target)
		total_scores.append(score)
	var score : int = average(total_scores)
	return score 

func average(list):
	var sum := 0.0
	for i in list:
		sum += i
	return sum/list.size()

func compute_range_all(actor : Character,move : Move,targets : Array[Character]):
	var score : int = 0
	
	var total_player_score : Array[int]
	for target in targets:
		var p_score : int
		if not target is Player:
			score -=10 
		else:
			p_score = super_effective(move,target) + attack_category(move,target) + kill_target(actor,move,target) + boosted(actor)
			total_player_score.append(p_score)
	score += average(total_player_score)
	return score

#endregion
#region CONDITIONS

func sp_cost(actor, move):
	if move.sp_cost > actor.sp:
		return -INF
	var ratio = float(actor.sp / actor.SP) * 0.9
	var cost_factor = float(move.sp_cost) / float(actor.SP)
	return int(-cost_factor * (1.0 - ratio) * 100)

func super_effective(move,target) :
	if move.type in target.weaknesses:
		return 50
	elif move.type in target.resistances:
		return -50
	else:
		return 0

func kill_target(actor,move,target):
	#do not count in normalization
	if target.compute_damage(actor,move) > target.hp:
		return 80
	else:
		return 0

func attack_category(move : AttackMove,target):
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

func boosted(actor):
	#attacks more if boosted, do not count in normalization
	if actor.matk > actor.MATK or actor.ratk > actor.RATK:
		return 50
	else:
		return 0

func heal(move,target):
	if target is Player or target.hp == target.HP:
		return -1000
	else:	
		if target.hp >= target.HP/2:
			return -10
		else:
			return 40

func status(move,target):
	for e in target.effects:
		if e.title == move.effect.title:
			return -10 
	return 50
			
#endregion
