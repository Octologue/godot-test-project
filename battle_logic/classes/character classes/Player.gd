extends Character
class_name Player

@export_range(0,2) var mult_hp : float
@export_range(0,2) var mult_sp : float
@export_range(0,2) var mult_ratk : float
@export_range(0,2) var mult_matk : float
@export_range(0,2) var mult_rdef : float
@export_range(0,2) var mult_mdef : float
@export_range(0,2) var mult_spe : float

@export var monster : Monster

var last_hp 
var last_sp 

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
	
func init_pair_moves():
	moveset += monster.moveset

func init_pair_lvl():
	monster.LVL = LVL
	monster.init_stats_by_lvl()

func init_pair():
	init_pair_lvl()
	init_pair_stats()
	init_pair_types()
	init_pair_moves()
	
func init():
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
	
	


	
