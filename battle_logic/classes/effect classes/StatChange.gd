extends Effect
class_name StatChange

@export var stat : Stats
enum Stats {RATK,RDEF,MATK,MDEF,SPE}

@export var power : float

func trigger(chara:Character):
	match stat:
		Stats.MATK:
			chara.matk *= power
		Stats.RATK:
			chara.ratk *= power
		Stats.MDEF:
			chara.mdef *= power
		Stats.RDEF:
			chara.rdef *= power
		Stats.SPE:
			chara.spe *= power
			
	print(chara.title,"'s stats changed")
	
func stop_trigger(chara:Character):
	match stat:
		Stats.MATK:
			chara.matk = chara.MATK
		Stats.RATK:
			chara.ratk = chara.RATK
		Stats.MDEF:
			chara.mdef = chara.MDEF
		Stats.RDEF:
			chara.rdef = chara.RDEF
		Stats.SPE:
			chara.spe = chara.SPE
			EventBus.speed_changed.emit()
	print(chara.title,"'s stats came back to normal")
