extends CharacterBody2D

@export var move_speed = 500

var health = 100

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = input_direction*move_speed

func _physics_process(_delta):
	get_input()
	move_and_slide()
