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

func compute_single_score(actor : Character,move : Move,target : Character,on_ally : bool) :
	return
	
func compute_multiple_scores(actor : Character,move : Move,targets : Array[Character], on_ally : bool):
	return

func compute_range_all(actor : Character,move : Move,targets : Array[Character]):
	return
