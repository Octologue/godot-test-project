extends ProgressBar

func set_max_hp(max_hp):
	max_value = max_hp
	
func update(new_hp):
	self.value = new_hp
