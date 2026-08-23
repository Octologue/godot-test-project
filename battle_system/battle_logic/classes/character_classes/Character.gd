extends BattleResource
class_name Character

# --- identity ---

@export var title : String
@export var sprite : Texture2D
@export var half_icon : Texture2D
@export var full_icon:Texture2D
var alive : bool = true
@export var LVL : int
#var no_ability : Ability = load("res://battle_system/data/abilities/no_ability.tres")
#@export var ability: Ability:
	#set(value):
		#if value == null:
			#ability = no_ability
		#else:
			#ability = value.duplicate(true)

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
		delay = 200 / (log(spe) + 2)  - 25
		delay = max(delay,1) #avoid bug <1
		print(delay)
		queue_reset()
var delay : float 
var queue : Array[float]

# --- battle interactions ---

@export var moveset : Array[Move]
var effects : Array

@export var resistances:Array[Types]
@export var weaknesses:Array[Types]
@export var attack_type:Types

var silenced := false

func init():
	pass

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
	queue.append(queue[-1]+delay)

func die():
	if not alive:
		return  
	alive = false

	BattleEvent.character_died.emit(self)

#endregion

#region MOVE COMPUTE

func get_attacked(attacker: Character, move: Move):
	if not alive:
		return
	var dmg := 0
	if randf()<= move.acc:
		dmg = compute_damage(attacker,move)
		hp -= dmg
		BattleEvent.damage_inflicted.emit(dmg, self)
		if randf() <= move.proc:
			effect_proc(move,attacker)
			BattleEvent.negative_luck.emit(self)
	else:
		BattleEvent.attack_missed.emit(self)
		BattleEvent.negative_luck.emit(attacker)
		pass
	
	if hp <= 0:
		die()
	return dmg

func compute_damage(attacker : Character,move : Move):
	var damage : int
	if move.category == move.Categories.MELEE:
		damage = (move.power * attacker.matk) / mdef
	elif move.category == move.Categories.RANGED:
		damage = (move.power * attacker.ratk) / rdef
		
	var type_modifier : float 
	var attack_type_modifier : float
		
	if move.type in weaknesses:
		type_modifier = 1.5
	elif move.type in resistances:
		type_modifier = 0.5
	else:
		type_modifier = 1
	
	if move.type == attacker.attack_type:
		attack_type_modifier = 1.5
		print("STAB")
	else:
		attack_type_modifier = 1

	damage = damage * randf_range(0.9,1.1) * type_modifier * attack_type_modifier
	
	return damage

func get_healed(move : Move):
	var hp_before = hp
	hp += move.power
	return hp-hp_before
	
func get_status(move : Move,attacker : Character):
	if randf() <= move.acc and randf() <= move.proc:
		effect_proc(move,attacker)
	return 1

func effect_proc(move:Move, attacker : Character):
	if move.effect is OneTimeEffect:
		move.effect.trigger(self,move,attacker)
	elif move.effect is StatusEffect:
		var new_effect = move.effect.duplicate()
		new_effect.sender = attacker
		add_effect(new_effect)
		BattleEvent.effect_to_copy.emit(new_effect,self)

func add_effect(effect : Effect):
		var new = true
		for e in effects:
			if e.title == effect.title:
				if effect.cumulable == true:
					e.duration += effect.duration
				new = false
				break
		if new != false:
			effect.owner = self
			effect.signal_init()
			effects.append(effect)
			effect.apply()
			BattleEvent.status_proc.emit(effect,self)

func effects_tick():
	for effect in effects:
		effect.duration -= 1
		if effect.duration < 0:
			effect.remove()
			effects.erase(effect)
			BattleEvent.status_stop.emit(effect,self)
		

#endregion

func level_up():
	pass
