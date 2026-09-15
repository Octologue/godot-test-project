class_name ActionResolver
extends Node

var action_result : BattleActionResult

func create_action_result(actor:Character, move: Move, targets: Array[Character]):
	action_result = BattleActionResult.new()
	action_result.actor = actor
	action_result.move = move
	
	if is_sp_enough(actor,move) == false:
		action_result.enough_sp = false
		return action_result
	else:
		action_result.enough_sp = true
	
	for target in targets:
		var target_result = BattleTarget.new()
		target_result.target = target
		move_compute(target_result,actor,move)
		action_result.targets.append(target_result)
	
	return action_result

func resolve_action(action : BattleActionResult):
	for target_result in action.targets:
		if target_result.missed :
			continue
		var target = target_result.target
		target.hp -= target_result.damage
		if target.hp <= 0:
			BattleEvent.character_died.emit(target)
		if target_result.effects.size()>0:
			target.effects.append_array(target_result.effects)
		

func is_sp_enough(actor:Character,move:Move):
	if move.sp_cost >= actor.sp:
		return false
	else:
		return true

func move_compute(target_result:BattleTarget,actor:Character,move:Move):
	if randf() <= move.accuracy:
		target_result.missed = false

		if move is AttackMove:
			attack_character(target_result,actor,move)
		elif move is HealMove:
			heal_character(target_result,move)
		elif move is StatusMove:
			status_character(target_result,move)
	else:
		target_result.missed = true

func attack_character(target_result:BattleTarget,actor:Character,move:AttackMove):

	target_result.damage = damage_compute(target_result,actor,move)
	
	if target_result.damage > target_result.target.hp:
		target_result.kill = true

	if randf()<= move.proc:
		target_result.effects = move.effects
		
	
func damage_compute(target_result:BattleTarget,actor:Character,move:AttackMove):
	var damage := 0
	var target = target_result.target
	if move.category == move.Category.MELEE:
		damage = (move.power * actor.matk) / target.mdef
	elif move.category == move.Category.RANGED:
		damage = (move.power * actor.ratk) / target.rdef
	
	damage = damage * randf_range(0.9,1.1) * get_type_modifier(target_result,move) * get_stab(actor,move)
	return damage

func get_type_modifier(target_result:BattleTarget,move:AttackMove):
	var target = target_result.target
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

func heal_character(target_result:BattleTarget,move:HealMove):
	var heal_amount = max(move.amount , target_result.target.HP)
	target_result.damage = -heal_amount

func status_character(target_result:BattleTarget,move:HealMove):
	target_result.effects = move.effects
