extends Resource

class_name Move

@export var title : String
@export var category : Categories
enum Categories {MELEE,RANGED,HEAL}
@export var power : int
@export_range(0,1) var acc : float
@export var sp_cost : int
