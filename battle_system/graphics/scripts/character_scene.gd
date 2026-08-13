extends Node2D

var character = Character
@onready var ui: BattleUI = $"../../UI"
@onready var bs: BattleSystem = $"/root/Main/BattleScene"
@onready var cursor = ui.find_child("cursor")

#TODO à adapter avec le nouveau système de sprite plus tard

func setup(chara):
	$Sprite2D.texture = chara.sprite
	character = chara
	$SelectionArea/CollisionShape2D.shape.size = $Sprite2D.texture.get_size()
	$SelectionArea/CollisionShape2D.position = $Sprite2D.texture.get_size()/2

func _on_selection_area_mouse_entered() -> void:
	if bs.state == bs.BattleState.PLAYER_TURN and character is Monster and bs.selection_is_ally == false:
		cursor_focus()
		
	if bs.selection_is_ally == true and character is Player:
		cursor_focus()

func _on_selection_area_mouse_exited() -> void:
	cursor.hide()

func _on_selection_area_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (bs.selection_is_enemy or bs.selection_is_ally) and Input.is_action_just_pressed("left click"):
		selected()

func cursor_focus():
	cursor.show()
	cursor.position = $Marker2D.global_position

func selected():
	if (bs.selection_is_ally and character is Player) or (bs.selection_is_enemy and character is Monster):
		BattleEvent.target_selected.emit(character)
		bs.selection_is_enemy = false
		bs.selection_is_ally = false
