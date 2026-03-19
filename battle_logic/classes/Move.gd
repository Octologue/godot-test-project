extends Resource

class_name Move


@export var title : String
@export var sp_cost : int
@export_range(0,1) var acc : float
@export var category : Categories
enum Categories {MELEE,RANGED,HEAL,STATUS}
@export var power : int
@export_range(0,1) var proc : float
@export var effect : Effect
@export var move_range : Ranges
enum Ranges {SELF, ENEMY, ALLY, ENEMIES, ALLIES,R_ENEMY,ALL}
