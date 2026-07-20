extends TextureProgressBar

var character : Character

func update_bar():
	max_value = character.HP
	value = character.hp
	self.get_parent().find_child("hpText").text = str(int(self.value)) + "/" + str(int(self.max_value))
	print("VALUE :",value)
