class_name Monster
extends Character

@export var base_HP : int
@export var base_SP : int
@export var base_MATK : int
@export var base_RATK : int
@export var base_MDEF : int
@export var base_RDEF : int
@export var base_AGI : int

var wild : bool = false
var wild_multiplier := 1.5

func initialize():
	temporary_lvl_init()
	hp = HP
	sp = SP
	matk = MATK
	ratk = RATK
	mdef = MDEF
	rdef = RDEF
	agi = AGI
	if !wild:
		return
	HP *= wild_multiplier
	SP *= wild_multiplier
	MATK *= wild_multiplier
	RATK *= wild_multiplier
	MDEF *= wild_multiplier
	RDEF *= wild_multiplier
	AGI *= wild_multiplier
	
func temporary_lvl_init():
	HP = base_HP 
	SP = base_SP 
	MATK = base_MATK 
	RATK = base_RATK 
	MDEF = base_MDEF 
	RDEF = base_RDEF
	AGI = base_AGI 
