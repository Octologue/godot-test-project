extends Resource
class_name Effect

@export var title : String
@export var icon : Texture2D
@export var duration : int #duration = 0 pour les effets sans duration (ex : life drain)
@export var cumulable : bool

func trigger(chara: Character):
	pass

func stop_trigger(chara:Character):
	pass
