extends Effect
class_name Poison

@export var damage : int

func trigger(chara: Character):
	chara.hp -= damage
	print (chara.title, " took ",damage," damage from poison and has ",chara.hp," HP ")
	
func stop_trigger(chara:Character):
	print(title, " stopped!")
