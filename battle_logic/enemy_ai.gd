var scores : Array[Dictionary]

func find_moves_and_targets(actor : Character,enemy_list:Array[Character] ,player_list:Array[Character]):
	var targets : Array[Character]
	var move : Move
	
	return {"target":targets,"move":move}

func compute_total_scores(actor,enemy_list,player_list):
	for move in actor.moveset:
		match move.range:
			move.Ranges.ENEMY:
				for p in player_list:
					scores.append({"targets":[p],"move":move,"score":compute_single_score(actor,move,p,false)})
			move.Ranges.ENEMIES:
				scores.append({"targets":player_list,"move":move,"score":compute_multiple_scores(actor,move,player_list,false)})
			move.Ranges.ALLY:
				for e in enemy_list:
					scores.append({"targets":[e],"move":move,"score":compute_single_score(actor,move,e,true)})
			move.Ranges.ALLIES:
				scores.append({"targets":enemy_list,"move":move,"score":compute_multiple_scores(actor,move,enemy_list,true)})
			move.Ranges.SELF:
				scores.append({"targets":[actor],"move":move,"score":compute_single_score(actor,move,actor,true)})
			move.Ranges.ALL:
				scores.append({"targets":[enemy_list+player_list],"move":move,"score":compute_range_all(actor,move,enemy_list+player_list)})

func compute_single_score(actor : Character,move : Move, target : Character, on_ally : bool) :
#compute for single target or self moves
	var score : int
	match move.category:
		move.Categories.MELEE or move.Categories.RANGED:
			score = super_effective(move,target)
		move.Categories.HEAL:
			pass
		move.Categories.STATUS:
			pass
	return score
	
func compute_multiple_scores(actor : Character,move : Move,targets : Array[Character], on_ally : bool):
#compute for multiple targets move
	return

func compute_range_all(actor : Character,move : Move,targets : Array[Character]):
#compute for explosions
	return

func super_effective(move,target) :
	if move.type in target.weaknesses:
		return 50
	elif move.type in target.resistances:
		return -50
	else:
		return 0
