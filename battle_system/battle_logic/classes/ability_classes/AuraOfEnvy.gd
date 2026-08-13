extends Ability
class_name AuraOfEnvy

var current_effect : StatChange

func init_signals():
	BattleEvent.effect_to_copy.connect(trigger)

func trigger(effect,target):
	if target == character:
		return
	if effect is StatChange :
		if effect.power > 1:
			var new_effect = effect.duplicate()
			new_effect.duration = 2
			new_effect.sender = null
			character.add_effect(new_effect)
