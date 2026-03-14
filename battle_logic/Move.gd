extends Resource

class_name Move

@export var category : Categories
enum Categories {MELEE,RANGED,HEAL}
@export var power : int
@export var cost : int
@export_range(0,1) var acc : float
