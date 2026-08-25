extends BattleResource
class_name Move

@export var title : String
@export var description : String

@export var sp_cost : int
@export_range(0,1) var acc : float
@export var type : Type
@export var effects : Array[Effect]

@export var move_range : MoveRange
enum MoveRange {SELF, ENEMY, ALLY, ENEMIES, ALLIES,ALL}
