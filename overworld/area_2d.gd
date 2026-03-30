extends Area2D

@export var battle_data : BattleData

func _on_body_entered(body: Node2D) :
	Globals.current_battle = battle_data
	#Globals.current_player_position = Globals.player_overworld.position
	get_tree().change_scene_to_file("res://battle_logic/scenes/battle_scene.tscn")
