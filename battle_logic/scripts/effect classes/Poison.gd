extends StatusEffect
class_name Poison

@export var damage : int
@export var frequency : int

func signal_init():
	BattleEvent.turn_end.connect(_on_turn_end)

func _on_turn_end():
	if duration%frequency == 0:
		owner.hp -= damage
		BattleEvent.hp_or_sp_changed.emit()
		BattleEvent.dmg_from_poison.emit(owner,damage)
		if owner.hp <= 0:
			owner.alive = false
			BattleEvent.character_died.emit(owner)
