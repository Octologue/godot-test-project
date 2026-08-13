extends Ability
class_name AuraOfRage

var raging_data := load("res://battle_system/data/effects/raging.tres")

func init_signals():
	BattleEvent.negative_luck.connect(trigger)

func trigger(unlucky):
	if unlucky == character:
		var new_effect = raging_data.duplicate()
		new_effect.sender = null
		print(new_effect.duration)
		character.add_effect(new_effect)
