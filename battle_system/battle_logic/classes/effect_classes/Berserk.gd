extends StatChange
class_name Berserk

func apply():
	match stat:
		Stats.MATK:
			owner.matk *= power
		Stats.RATK:
			owner.ratk *= power
	owner.silenced = true


func remove():
	match stat:
		Stats.MATK:
			owner.matk = owner.MATK
		Stats.RATK:
			owner.ratk = owner.RATK
	owner.silenced = false
