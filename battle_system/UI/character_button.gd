extends Button

var character : Character:
	set(value):
		character = value
		text = value.title

func _on_pressed() -> void:
	BattleEvent.target_selected.emit(character)
