extends CharacterBody2D

@export var move_speed = 150

func get_input():
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")

	velocity = Vector2.ZERO

	if up:
		velocity.y = -move_speed

	if down:
		velocity.y = move_speed

	if left:
		velocity.x = -move_speed

	if right:
		velocity.x = move_speed

func _physics_process(delta):
	get_input()
	move_and_slide()
