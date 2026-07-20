extends Character
class_name Player

@export_range(0,2) var mult_hp : float
@export_range(0,2) var mult_sp : float
@export_range(0,2) var mult_ratk : float
@export_range(0,2) var mult_matk : float
@export_range(0,2) var mult_rdef : float
@export_range(0,2) var mult_mdef : float
@export_range(0,2) var mult_spe : float

@export var monster : Monster:
	set(value):
		if value == null:
			monster = no_monster
		else:
			monster = value
var no_monster : Monster = preload("res://battle_system/data/monsters/no_monster.tres")

var last_hp 
var last_sp 

var XP : int

func init_pair_stats():
	HP = mult_hp*monster.HP
	SP = mult_sp*monster.SP
	MATK = mult_matk*monster.MATK
	RATK = mult_ratk*monster.RATK
	MDEF = mult_mdef*monster.MDEF
	RDEF = mult_rdef*monster.RDEF
	SPE = mult_spe*monster.SPE

func init_pair_types():
	resistances = monster.resistances
	weaknesses = monster.weaknesses
	attack_type = monster.attack_type
	
func init_pair_moves():
	for i in monster.moveset:
		if i not in moveset:
			moveset.append(i)

func init_pair_lvl():
	monster.LVL = LVL
	monster.init_stats_by_lvl()

func init_pair():
	init_pair_lvl()
	init_pair_stats()
	init_pair_types()
	init_pair_moves()
	
func init():
	init_pair()
	matk = MATK
	ratk = RATK
	mdef = MDEF
	rdef = RDEF
	spe = SPE
	def_count = 0
	if last_hp == null or last_sp == null:
		hp = HP
		sp = SP
	else:
		hp = last_hp
		sp = last_sp
	
func add_xp(amount):
	XP += amount
	print(xp_to_next_lvl())
	while XP >= xp_to_next_lvl():
		XP -= xp_to_next_lvl()
		LVL+=1
		init()
		print(title," got to level ",LVL," stats : HP = ",HP," hp = ",hp)

func xp_to_next_lvl():
	return 2*LVL*LVL+100*LVL

	
