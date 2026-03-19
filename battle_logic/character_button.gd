extends Button

@export var character : Character :
	set(value):
		character = value
		text = value.title
		

func _on_pressed():
	EventBus.target_selected.emit(character)
