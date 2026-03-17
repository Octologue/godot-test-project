extends Effect
class_name Poison

@export var damage : int

func trigger(chara: Character):
	chara.HP -= damage
