extends BattleResource
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
var effects : Array

@export var resistances:Array[Types]
@export var weaknesses:Array[Types]

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
			damage = (move.power * attacker.MATK) / MDEF
		elif move.category == move.Categories.RANGED:
			damage = (move.power * attacker.RATK) / RDEF
		
		var type_modifier : float = 1
		
		if not move.type == Types.NEUTRAL:
			if not weaknesses.is_empty():
				for w in weaknesses:
					if w == move.type:
						type_modifier = 1.5
						print ("weak to ",move.type)
			if not resistances.is_empty():
				for r in resistances:
					if r == move.type:
						type_modifier = 0.5
						print ("resist ",move.type)

		damage = damage * randf_range(0.9,1.1) * type_modifier
		
		HP -= damage
		print(title, " attacked by ", attacker.title, " with ",move.title, " and now has ", HP, " HP.")
		
		if randf() <= move.proc:
			effect_proc(move.effect)
		
	else:
		print(attacker.title," attack's missed ",title)
	
	if HP <= 0:
		die()

func effect_proc(effect:Effect):
	var new = true
	for e in effects:
		if e.title == effect.title:
			if effect.cumulable == true:
				e.duration += effect.duration
			new = false
			break
	if new != false:
		var new_effect = effect.duplicate()
		effects.append(new_effect)
		if new_effect is StatChange:
			new_effect.trigger(self)
			if new_effect.stat == SPE:
				EventBus.speed_changed.emit()
		
	print (effect.title, " has proc and affect ", title)

func effects_trigger():
	for effect in effects:
		effect.duration -= 1
		if effect is not StatChange:
			effect.trigger(self)
			if HP <= 0:
				die()
		if effect.duration == 0:
			effect.stop_trigger(self)
			effects.erase(effect)
			if effect is StatChange and effect.stat == SPE:
				EventBus.speed_changed.emit()

	
func die():
	if not alive:
		return  
	alive = false
	print(title, " died")

	EventBus.character_died.emit(self)
