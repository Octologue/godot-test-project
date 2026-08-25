extends Node2D

var character = Character 


func setup(new_character):
	character = new_character
	$Sprite2D.texture = character.sprite
	if character is Monster:
		if character.wild == true:
			$Sprite2D.flip_h = true
