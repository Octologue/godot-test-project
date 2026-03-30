extends CharacterBody2D

@export var speed = 100

var direction : String
var last_facing : String
var animation : String = "idle_down"
@onready var animated_sprite = $AnimatedSprite2D

func ready():
	direction = "down"
	animated_sprite.play("idle_down")

func get_input():
	var raw_input = Input.get_vector("left","right","up","down")
	velocity = raw_input * speed
	print(raw_input)
	print(velocity)
	
	if raw_input.length() > 0: # Check if we're moving
		if abs(raw_input.x) > abs(raw_input.y): # Horizontal or vertical? (prioritizing vertical movement)
			direction = "left" if raw_input.x < 0 else "right"
		else:
			direction = "up" if raw_input.y < 0 else "down"

	animation = ("walk" if velocity.length() > 0.0 else "idle") + "_" + direction
	animated_sprite.play(animation)

func _physics_process(delta: float) :
	get_input()
	move_and_slide()
