extends BattleResource
class_name Character

# --- identity ---

@export var title : String
@export var sprite : Texture2D
@export var is_player : bool
var alive : bool = true


# --- main stats ---

@export var HP : int
var hp : int:
	set(value):
		hp = clamp(value,0,HP)
@export var SP : int
var sp : int:
	set(value):
			sp = clamp(value,0,SP)

# --- offense and defense ---

@export var MATK : int
var matk : int 
@export var RATK : int
var ratk : int
@export var MDEF : int 
var mdef : int
@export var RDEF : int
var rdef : int

# --- turn order ---

@export var SPE : int 
var spe : int :
	set(value):
		spe = value
		delay = 200 / (log(spe) + 2) - 25
		delay = max(delay,1) #avoid bug <1
		queue_reset()
var delay : float 
var queue : Array[float]

# --- battle interactions ---

@export var moveset : Array[Move]
var effects : Array

@export var resistances:Array[Types]
@export var weaknesses:Array[Types]

# --- defending ---

var defending : bool = false
var hold_def : Array[int] 
var def_count : int 

func init_stats():
#appeler au début du combat et à la fin lors des montées de lvl
	matk = MATK
	ratk = RATK
	mdef = MDEF
	rdef = RDEF
	spe = SPE
	sp = SP
	hp = HP
	def_count = 0
	

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

func defending_check():
	if defending : 
		def_count += 1
		if def_count == 1:
			hold_def = [rdef,mdef]
			rdef *= 5
			mdef *= 5
	if def_count > 3 :
		defending = false
		rdef = hold_def[0]
		mdef = hold_def[1]
		def_count = 0

func get_attacked(attacker: Character, move: Move):
	if not alive:
		return
	
	if randf()<= move.acc:
		hp -= compute_damage(attacker,move)
		print(title, " attacked by ", attacker.title, " with ",move.title, " and now has ", hp, " HP.")
		
		if randf() <= move.proc:
			effect_proc(move.effect)
	else:
		print(attacker.title," attack's missed ",title)
	
	if hp <= 0:
		die()

func compute_damage(attacker,move):
	var damage : int
	if move.category == move.Categories.MELEE:
		damage = (move.power * attacker.matk) / mdef
	elif move.category == move.Categories.RANGED:
		damage = (move.power * attacker.ratk) / rdef
		
	var type_modifier : float 
		
	if move.type in weaknesses:
		type_modifier = 1.5
		print ("weak to ",move.type)
	elif move.type in resistances:
		type_modifier = 0.5
		print ("resist ",move.type)
	else:
		type_modifier = 1

	damage = damage * randf_range(0.9,1.1) * type_modifier
	print("damage = ",damage)
	return damage

func get_healed(move : Move):
	hp += move.power
	print(title," get healed ",move.power," and now has ",hp," HP")

func get_status(move : Move):
	if randf() <= move.acc and randf() <= move.proc:
		effect_proc(move.effect)

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
			if new_effect.stat == effect.Stats.SPE:
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
			if effect is StatChange and effect.stat == effect.Stats.SPE:
				EventBus.speed_changed.emit()

func die():
	if not alive:
		return  
	alive = false
	print(title, " died")

	EventBus.character_died.emit(self)

func get_sp():
	return sp
