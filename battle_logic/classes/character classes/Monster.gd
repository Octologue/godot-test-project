extends Character
class_name Monster

@export var LVL_s : int
@export var LVL_r : int
@export var LVL_g : int
@export var LVL_m : int
@export var xp_base : int
var wild : bool = false

func mon_level_up(chara : Player):
	pass #apprendra des movesets en fonction du personnage

func init_stats_by_lvl():
	HP += LVL*2
	SP += LVL*2
	MATK += LVL*2
	RATK += LVL*2
	MDEF += LVL*2
	RDEF += LVL*2
	SPE += LVL*2

func init():
	var mult := 0.0
	if wild:
		mult = 1.5
	init_stats_by_lvl()
	matk = MATK*mult
	ratk = RATK*mult
	mdef = MDEF*mult
	rdef = RDEF*mult
	spe = SPE*mult
	sp = SP*mult
	hp = HP*mult
	
