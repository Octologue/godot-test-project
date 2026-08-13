extends Character
class_name Monster

var LVL_s : int
var LVL_r : int
var LVL_g : int
var LVL_m : int

@export var xp_base : int

@export var base_HP : int
@export var base_SP : int
@export var base_MATK : int
@export var base_RATK : int
@export var base_MDEF : int
@export var base_RDEF : int
@export var base_SPE : int

var wild : bool = false

func mon_level_up(chara : Player):
	pass #apprendra des movesets en fonction du personnage

func init_stats_by_lvl():
	HP = base_HP + LVL*2
	SP = base_SP + LVL*2
	MATK = base_MATK + LVL*2
	RATK = base_RATK + LVL*2
	MDEF = base_MDEF + LVL*2
	RDEF = base_RDEF + LVL*2
	SPE = base_SPE + LVL*2

func init():
	var mult := 0.0
	if wild:
		mult = 1.5
	ability.init(self)
	init_stats_by_lvl()
	MATK = MATK*mult
	RATK = RATK*mult
	MDEF = MDEF*mult
	RDEF = RDEF*mult
	SPE = SPE*mult
	SP = SP*mult
	if wild:
		SP*=2
	HP = HP*mult
	matk = MATK
	ratk = RATK
	mdef = MDEF
	rdef = RDEF
	spe = SPE
	hp = HP
	sp = SP
