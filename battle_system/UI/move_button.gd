extends Button

var move : Move:
	set(value):
		move = value
		text = value.title

func _on_pressed() -> void:
	BattleEvent.move_button_pressed.emit(move)
