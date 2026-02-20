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
		queue_reset()
var delay : float
var queue : Array[float]
var node

func queue_reset():
#créer 8 valeurs d'après une suite arithmétique
#pour avoir les positions du personnage dans la timeline
	queue.clear()
	for i in range(8):
		if queue.is_empty():
			queue.append(delay)
		else:
			queue.append(queue[-1] + delay)

func pop_out():
	queue.pop_front()
	queue.append(queue[-1]*delay)

func tween_movement(shift, tree):
	if not alive or node == null:
		return
	var tween = tree.create_tween()
	tween.tween_property(node, "position", node.position + shift, 0.2)
	await tween.finished
	
func get_attacked(attacker: Character):
	if not alive:
		return
	HP -= attacker.ATK
	print(title, " a été attaqué par ", attacker.title, " et a maintenant ", HP, " HP.")
	if HP <= 0:
		return
