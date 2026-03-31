extends CharacterBody2D

@export var battle_data : BattleData


func _on_area_2d_body_entered(body: Node2D) :
	var main = get_tree().get_first_node_in_group("main")
	if body == $"../PlayerOverworld":
		main.initiate_battle_encounter(self)
