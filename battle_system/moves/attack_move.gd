extends Move
class_name AttackMove

@export var damage : int
@export_range(0,1) var proc : float
@export var category : Category
enum Category {MELEE,RANGED}
