extends ProgressBar

var character : Character

func update_bar():
	max_value = character.HP
	value = character.hp
