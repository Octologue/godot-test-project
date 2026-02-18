extends Resource
class_name Character

@export var title : String
@export var sprite : Texture2D
@export var is_player : bool
var alive : bool = true


@export var ATK : int
@export var HP : int:
	set (value):
		HP = value
		var max_hp = HP
		clamp (HP, 0, max_hp)

@export var SPE : int : 
	set(value):
		SPE = value
		delay = 200 / (log(SPE) + 2) - 25
var delay : float
var queue : Array[float]

func queue_reset():
	queue.clear()
	for i in range(4):
		if queue.is_empty():
			queue.append(delay)
		else:
			queue.append(queue[-1] + delay)
