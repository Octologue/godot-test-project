extends Resource
class_name Ability

@export var title : String
@export var description : String
var character : Character

func init(chara):
	character = chara
	init_signals()

func init_signals():
	pass
	
