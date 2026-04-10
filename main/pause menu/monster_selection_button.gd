extends Button

var monster : Monster:
	set(value):
		monster = value
		text = value.title

func _on_pressed() -> void:
	EventBus.selected_monster.emit(monster)
