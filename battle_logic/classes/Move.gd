extends Resource

class_name Move

enum Categories {MELEE,RANGED,HEAL,STATUS}
@export var title : String
@export var sp_cost : int
@export_range(0,1) var acc : float
@export var category : Categories
@export var power : int
@export_range(0,1) var proc : float
@export var effect : Effect
