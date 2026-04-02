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
	
func match_pair(mon : Monster):
	if mon.tamed:
		monster = mon
		init_pair_stats()
		init_pair_types()


	
