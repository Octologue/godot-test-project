class_name Player
extends Character

@export_range(0,2) var mult_hp : float
@export_range(0,2) var mult_sp : float
@export_range(0,2) var mult_ratk : float
@export_range(0,2) var mult_matk : float
@export_range(0,2) var mult_rdef : float
@export_range(0,2) var mult_mdef : float
@export_range(0,2) var mult_agi : float

@export var monster : Monster:
	set(value):
		if value == null:
			monster = no_monster
		else:
			monster = value

var no_monster : Monster = preload("res://battle_system/resources/no_monster.tres")
var last_hp 
var last_sp 

func initialize():
	pair_player_with_monster()
	
	matk = MATK
	ratk = RATK
	mdef = MDEF
	rdef = RDEF
	agi = AGI
	
	if last_hp == null or last_sp == null:
		hp = HP
		sp = SP
	else:
		hp = last_hp
		sp = last_sp
		
	if hp <= 0:
		alive = false
	else:
		alive = true

func pair_player_with_monster():
	monster.initialize()
	
	HP = mult_hp*monster.HP
	SP = mult_sp*monster.SP
	MATK = mult_matk*monster.MATK
	RATK = mult_ratk*monster.RATK
	MDEF = mult_mdef*monster.MDEF
	RDEF = mult_rdef*monster.RDEF
	AGI = mult_agi*monster.AGI
	
	resistances = monster.resistances
	weaknesses = monster.weaknesses
	attack_type = monster.attack_type
	
	for i in monster.moveset:
		if i not in moveset:
			moveset.append(i)
