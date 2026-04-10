extends Button

var move : Move :
	set(value):
		move = value
		text = value.title
		

func _on_pressed():
	EventBus.selected_move.emit(move)
