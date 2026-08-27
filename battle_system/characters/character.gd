extends BattleResource
class_name Character

@export var title : String
@export var sprite : Texture2D
@export var icon : Texture2D
@export var LVL : int

var HP : int
var hp : int:
	set(value):
		hp = clamp(value,0,HP)

var SP : int
var sp : int:
	set(value):
			sp = clamp(value,0,SP)

var MATK : int
var mod_atk := 1.0
var matk : int 

var RATK : int
var mod_ratk := 1.0
var ratk : int

var MDEF : int 
var mod_mdef := 1.0
var mdef : int

var RDEF : int
var mod_rdef := 1.0
var rdef : int

var AGI : int 
var mod_agi := 1.0
var agi : int

@export var moveset : Array[Move]
var effects : Array
@export var resistances:Array[Type]
@export var weaknesses:Array[Type]
@export var attack_type:Type

var ally : bool
var alive : bool = true

func initialize():
	pass

func receive_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func heal(amount):
	hp += amount

func die():
	if not alive:
		return  
	alive = false
	BattleEvent.character_died.emit(self)

func add_effect(effect):
	effects.append(effect)
