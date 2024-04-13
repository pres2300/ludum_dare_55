extends CharacterBody2D

@export var move_speed = 500

var health = 100

# Objective counters
var current_summoning_items : int = 0

func pickup_summoning_item():
	current_summoning_items += 1

func drop_summoning_item():
	if current_summoning_items > 0:
		current_summoning_items -= 1
		return true
	else:
		return false

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	velocity = input_direction*move_speed

func _physics_process(_delta):
	get_input()
	move_and_slide()
