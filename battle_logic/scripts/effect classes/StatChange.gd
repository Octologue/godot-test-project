extends StatusEffect
class_name StatChange

@export var stat : Stats
enum Stats {RATK,RDEF,MATK,MDEF,SPE}

@export var power : float

func apply():
	match stat:
		Stats.MATK:
			owner.matk *= power
		Stats.RATK:
			owner.ratk *= power
		Stats.MDEF:
			owner.mdef *= power
		Stats.RDEF:
			owner.rdef *= power
		Stats.SPE:
			BattleEvent.speed_changed.emit()
			owner.spe *= power


func remove():
	match stat:
		Stats.MATK:
			owner.matk = owner.MATK
		Stats.RATK:
			owner.ratk = owner.RATK
		Stats.MDEF:
			owner.mdef = owner.MDEF
		Stats.RDEF:
			owner.rdef = owner.RDEF
		Stats.SPE:
			owner.spe = owner.SPE
			BattleEvent.speed_changed.emit()
