extends TextureProgressBar

var character : Character

func update_bar():
	max_value = character.SP
	value = character.sp
	self.get_parent().find_child("spText").text = str(int(self.value)) + "/" + str(int(self.max_value))
