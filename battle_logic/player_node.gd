extends Node2D

@onready var sprite = $Sprite2D


func setup(data):
	sprite.texture = data.sprite
