extends Button

var move : Move :
	set(value):
		move = value
		text = value.title
		

func _on_pressed():
	BattleEvent.selected_move.emit(move)
