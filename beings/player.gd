extends CharacterBody2D

@export var move_speed = 500

@onready var weapon_path = $WeaponPath
@onready var weapon_start_location = $WeaponLocation.position
var weapon = null

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

func add_weapon(new_weapon : PackedScene):
	weapon = new_weapon.instantiate()
	weapon_path.add_child(weapon)
	weapon.position = weapon_path.curve.get_closest_point(weapon_start_location - weapon.get_hold_position())

func get_weapon_input():
	return Input.get_vector("attack_left", "attack_right", "attack_up", "attack_down")

func get_input():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _physics_process(_delta):
	var input_direction = get_input()
	velocity = input_direction*move_speed
	move_and_slide()

func _process(_delta):
	var attack_direction = get_weapon_input()
	if attack_direction != Vector2.ZERO and weapon:
		var attack_target_position = position + 1000*attack_direction
		var dir = global_position.direction_to(attack_target_position)
		if dir.x > 0:
			weapon.flip_h = false
		else:
			weapon.flip_h = true
		weapon.set_target_rotation(dir.angle())
		weapon.position = weapon_path.curve.get_closest_point(weapon_path.to_local(attack_target_position))
		weapon.start_attacking()
	elif weapon:
		weapon.stop_attacking()
