extends OneTimeEffect
class_name Drain

@export var power : float

func trigger(target:Character, move : Move, sender : Character):
	var hp_drained
	if move.category == move.Categories.MELEE or move.Categories.RANGED:
		var dmg = target.compute_damage(sender,move)
		hp_drained = dmg*power
	else:
		hp_drained = power * 100
	print(hp_drained)
	target.hp -= hp_drained
	sender.hp += hp_drained
	BattleEvent.hp_or_sp_changed.emit()
