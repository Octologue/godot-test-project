class_name ActionResolver
extends Node

#resolve_action() return a resource containing every consequence of that action
#the array targets is made of dictionaries like follow:
#var example_dico={
	#"character":Character,
	#"missed" : bool,
	#"damage":int, (negative if healing)
	#"died":bool,
	#"effects":Array[Effect]
#}

func resolve_action(actor:Character, move: Move, targets: Array[Character]):
	var action_result = BattleActionResult.new()
	action_result.actor = actor
	action_result.move = move
	
	if is_sp_enough(actor,move) == false:
		action_result.enough_sp = false
		return action_result
	else:
		action_result.enough_sp = true
	
	for target in targets:
		var target_result = {
			"character":target,
		}
		move_compute(target_result,actor,move)
		action_result.targets.append(target_result)
	
	return action_result

func is_sp_enough(actor:Character,move:Move):
	if move.sp_cost >= actor.sp:
		return false
	else:
		return true

func move_compute(target_result:Dictionary,actor:Character,move:Move):
	if randf() <= move.accuracy:
		target_result["missed"] = false

		if move is AttackMove:
			attack_character(target_result,actor,move)
		elif move is HealMove:
			heal_character(target_result,move)
		elif move is StatusMove:
			status_character(target_result,move)

	else:
		target_result["missed"] = true

func attack_character(target_result:Dictionary,actor:Character,move:AttackMove):

	target_result["damage"] = damage_compute(target_result["character"],actor,move)
	target_result["character"].hp -= target_result["damage"]
		
	if target_result["character"].hp <= 0:
		target_result["died"] = true
		BattleEvent.character_died.emit(target_result["character"])
	else:
		target_result["died"] = false
			
	if randf()<= move.proc:
		target_result["effects"] = move.effects
		target_result["character"].effects.append_array(move.effects)
	
func damage_compute(target:Character,actor:Character,move:AttackMove):
	var damage := 0
	
	if move.category == move.Categories.MELEE:
		damage = (move.power * actor.matk) / target.mdef
	elif move.category == move.Categories.RANGED:
		damage = (move.power * actor.ratk) / target.rdef
	
	damage = damage * randf_range(0.9,1.1) * get_type_modifier(target,move) * get_stab(actor,move)
	return damage

func get_type_modifier(target:Character,move:AttackMove):
	if move.type in target.weaknesses:
		return 1.5
	elif move.type in target.resistances:
		return 0.5
	else:
		return 1

func get_stab(actor:Character,move:AttackMove):
	if move.type == actor.attack_type:
		return 1.5
	else:
		return 1

func heal_character(target_result:Dictionary,move:HealMove):
	target_result["damage"] = -move.amount
	target_result["character"].hp += move.amount

func status_character(target_result:Dictionary,move:HealMove):
	target_result["effects"] = move.effects
	target_result["character"].effects.append_array(move.effects)
