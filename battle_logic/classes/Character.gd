extends Resource
class_name Character

@export var title : String
@export var sprite : Texture2D
@export var is_player : bool
var alive : bool = true


@export var HP : int:
	set (value):
		HP = value
		var max_hp = HP
		clamp (HP, 0, max_hp)
@export var SP : int:
	set(value):
		SP = value
		var max_sp = SP
		clamp (SP, 0, max_sp)
@export var MATK : int
@export var RATK : int
@export var MDEF : int
@export var RDEF : int

@export var SPE : int : 
	set(value):
		SPE = value
		delay = 200 / (log(SPE) + 2) - 25
		queue_reset()
var delay : float
var queue : Array[float]

@export var moveset : Array[Move]
var status_effects : Array

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
	if not alive:
		return
	queue.pop_front()
	queue.append(queue[-1]*delay)
	
func get_attacked(attacker: Character, move: Move):
	if not alive:
		return
	
	if randf()<= move.acc:
		var damage : int
		if move.category == move.Categories.MELEE:
			@warning_ignore("integer_division")
			damage = (move.power * attacker.MATK) / MDEF
		elif move.category == move.Categories.RANGED:
			@warning_ignore("integer_division")
			damage = (move.power * attacker.RATK) / RDEF
			
		@warning_ignore("narrowing_conversion")
		damage *= randf_range(0.9,1.1)
		
		HP -= damage
		
		print(title, " attacked by ", attacker.title, " with ",move.title, " and now has ", HP, " HP.")
		
	else:
		print(attacker.title," attack's missed ",title)
	
	
	if HP <= 0:
		die()



		
func die():
	if not alive:
		return  
	alive = false
	print(title, " died")

	EventBus.character_died.emit(self)
