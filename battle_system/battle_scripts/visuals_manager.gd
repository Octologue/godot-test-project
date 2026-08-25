class_name VisualsManager
extends BattleController

@onready var allies = $"../../AlliesSprites"
@onready var enemies = $"../../EnemiesSprites"
@onready var character_scene = preload("res://battle_system/visuals/character_sprite.tscn")

func player_sprite_init(player,position):
	var new_scene = character_scene.instantiate()
	new_scene.setup(player)
	new_scene.position = position
	allies.add_child(new_scene)
	
func enemy_sprite_init(enemy,position):
	var new_scene = character_scene.instantiate()
	new_scene.setup(enemy)
	new_scene.position = position
	enemies.add_child(new_scene)
	
