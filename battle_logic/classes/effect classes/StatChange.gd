extends Effect
class_name StatChange

@export var stat : Stats
enum Stats {RATK,RDEF,MATK,MDEF,SPE}

@export var power : float

var base_stat : int

func trigger(chara:Character):
	match stat:
		Stats.MATK:
			base_stat = chara.MATK
			chara.MATK *= power
		Stats.RATK:
			base_stat = chara.RATK
			chara.RATK *= power
		Stats.MDEF:
			base_stat = chara.MDEF
			chara.MDEF *= power
		Stats.RDEF:
			base_stat = chara.RDEF
			chara.RDEF *= power
		Stats.SPE:
			base_stat = chara.SPE
			chara.SPE *= power

func stop_trigger(chara:Character):
	match stat:
		Stats.MATK:
			chara.MATK = base_stat
		Stats.RATK:
			chara.RATK = base_stat
		Stats.MDEF:
			chara.MDEF = base_stat
		Stats.RDEF:
			chara.RDEF = base_stat
		Stats.SPE:
			chara.SPE = base_stat
