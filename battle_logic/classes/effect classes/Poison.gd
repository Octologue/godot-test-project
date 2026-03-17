extends Effect
class_name Poison

@export var damage : int

func trigger(chara: Character):
	chara.HP -= damage
	print (chara.title, " took ",damage," damage from poison and has ",chara.HP," HP ")
	
func stop_trigger(chara:Character):
	print(title, " stopped!")
