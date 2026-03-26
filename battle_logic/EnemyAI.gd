
class_name EnemyAI

var scores : Array[Dictionary]
#TODO établir des behaviors différents (ex : enemy qui soigne bcp)

func find_moves_and_targets(actor : Character,enemy_list:Array[Character] ,player_list:Array[Character]):
	var choosed_targets : Array
	var choosed_move : Move
	
	compute_total_scores(actor,enemy_list,player_list)
	scores.sort_custom(sort_by_score)
	for s in scores: #print
		var target_names := []
		for t in s["targets"]:
			target_names.append(t.title)
		print("Move:", s["move"].title,
		  "| Targets:", target_names,
		  "| Score:", s["score"])
	
	var total := 0
	var weights : Array[Dictionary]
	for s in scores: 
		var new_score := 0
		if s["score"] >= -20:
			new_score = int(pow(20 + s["score"],0.5))
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
			choosed_targets = action["targets"]
			choosed_move = action["move"]
			break
	
	scores.clear()
	cumul = 0
	print(actor.title," choosed move : ", choosed_move.title," and targets : ",choosed_targets.map(func(i):return i.title))
	return {"targets":choosed_targets,"move":choosed_move}

func sort_by_score(a,b):
	return a["score"] > b["score"]


#region SCORE COMPUTING

func compute_total_scores(actor,enemy_list,player_list):
	for move in actor.moveset:
		match move.move_range:
			move.Ranges.ENEMY:
				for p in player_list:
					scores.append({"targets":[p],"move":move,"score":compute_score(actor,move,[p])})
			move.Ranges.ENEMIES:
				scores.append({"targets":player_list,"move":move,"score":compute_score(actor,move,player_list)})
			move.Ranges.ALLY:
				for e in enemy_list:
					scores.append({"targets":[e],"move":move,"score":compute_score(actor,move,[e])})
			move.Ranges.ALLIES:
				scores.append({"targets":enemy_list,"move":move,"score":compute_score(actor,move,enemy_list)})
			move.Ranges.SELF:
				scores.append({"targets":[actor],"move":move,"score":compute_score(actor,move,actor)})
			move.Ranges.ALL:
				scores.append({"targets":enemy_list+player_list,"move":move,"score":compute_range_all(actor,move,enemy_list+player_list)})

func compute_score(actor : Character,move : Move, targets : Array[Character]) :
#compute for single target or self moves
	var total_scores :Array[int]
	for target in targets:
		
		var score : int
		match move.category:
			move.Categories.MELEE, move.Categories.RANGED:
				score = sp_cost(actor,move)\
				 + super_effective(move,target)\
				 + attack_category(move,target)\
				 + kill_target(actor,move,target)\
				 + boosted(actor)
				#print(
				#"---------------------------- \n",
				#"Move: ", move.title, " | Target: ", target.title, "\n",
				#"sp_cost: ", sp_cost(actor,move), "\n",
				#"super_effective: ", super_effective(move,target), "\n",
				#"attack_category: ", attack_category(move,target), "\n",
				#"kill_target:" , kill_target(actor,move,target), "\n",
				#"boosted: ", boosted(actor), "\n",
				#"TOTAL:", score,"\n",
				#"----------------------------"
				#)
			move.Categories.HEAL:
				score = sp_cost(actor,move) + heal(move,target)
			move.Categories.STATUS:
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
	var score : int = -40 #TODO équilibrer freq explosions ici
	var total_player_score : Array[int]
	for target in targets:
		var p_score : int
		if not target.is_player:
			if target.hp < target.HP/3:
				score += 10
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
		print("achève l'enemy")
		return 80
	else:
		return 0

func attack_category(move,target):
	if move.category == move.Categories.MELEE:
		if target.mdef<=target.rdef:
			return 0
		else : 
			return -20
	if move.category == move.Categories.RANGED:
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
	if target.is_player or target.hp == target.HP:
		return -1000
	else:	
		if target.hp >= target.HP/2:
			return -10
		else:
			return 50

func status(move,target):
	for e in target.effects:
		if e.title == move.effect.title:
			return -10 #pas -1000 car ça peux ajouter de la duration
	return 50
			
#endregion
