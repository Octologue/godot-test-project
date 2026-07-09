extends BattleResource
class_name Character

# --- identity ---

@export var title : String
@export var sprite : Texture2D
var alive : bool = true
@export var LVL : int

# --- main stats ---

var HP : int
var hp : int:
	set(value):
		hp = clamp(value,0,HP)
var SP : int
var sp : int:
	set(value):
			sp = clamp(value,0,SP)

# --- offense and defense ---

var MATK : int
var matk : int 
var RATK : int
var ratk : int
var MDEF : int 
var mdef : int
var RDEF : int
var rdef : int

# --- turn order ---

var SPE : int 
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


#region INIT
	

func init():
#appeler au début du combat
	pass

#endregion

#region LOGIC

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

func die():
	if not alive:
		return  
	alive = false

	BattleEvent.character_died.emit(self)

#endregion

#region MOVE COMPUTE

func defending_check():
	if defending : 
		def_count += 1
		sp += 30
		if def_count == 1:
			hold_def = [rdef,mdef]
			rdef *= 5
			mdef *= 5
			BattleEvent.started_defending.emit(self)
	if def_count > 3 :
		defending = false
		rdef = hold_def[0]
		mdef = hold_def[1]
		def_count = 0
		BattleEvent.stoped_defending.emit(self)

func get_attacked(attacker: Character, move: Move):
	if not alive:
		return
	var dmg := 0
	if randf()<= move.acc:
		dmg = compute_damage(attacker,move)
		hp -= dmg
		BattleEvent.damage_inflicted.emit(dmg, self)
		if randf() <= move.proc:
			effect_proc(move, attacker)
	else:
		BattleEvent.attack_missed.emit(self)
		pass
		
	
	if hp <= 0:
		die()
	return dmg

func compute_damage(attacker,move):
	var damage : int
	if move.category == move.Categories.MELEE:
		damage = (move.power * attacker.matk) / mdef
	elif move.category == move.Categories.RANGED:
		damage = (move.power * attacker.ratk) / rdef
		
	var type_modifier : float 
		
	if move.type in weaknesses:
		type_modifier = 1.5
	elif move.type in resistances:
		type_modifier = 0.5
	else:
		type_modifier = 1

	damage = damage * randf_range(0.9,1.1) * type_modifier
	
	return damage

func get_healed(move : Move):
	var hp_before = hp
	hp += move.power
	
	return hp-hp_before
	
func get_status(move : Move, attacker : Character):
	if randf() <= move.acc and randf() <= move.proc:
		effect_proc(move, attacker)
	return 1

func effect_proc(move:Move, attacker : Character):
	if move.effect is OneTimeEffect:
		move.effect.trigger(self,move,attacker)
	elif move.effect is StatusEffect:
		var new = true
		for e in effects:
			if e.title == move.effect.title:
				if move.effect.cumulable == true:
					e.duration += move.effect.duration
				new = false
				break
		if new != false:
			var new_effect = move.effect.duplicate()
			new_effect.owner = self
			new_effect.sender = attacker
			new_effect.signal_init()
			effects.append(new_effect)
			new_effect.apply()
			BattleEvent.status_proc.emit(new_effect,self)

func effects_tick():
	for effect in effects:
		effect.duration -= 1
		if effect.duration == 0:
			BattleEvent.status_stop.emit(effect,self)
			effect.remove()
			effects.erase(effect)

#endregion

func level_up():
	pass
