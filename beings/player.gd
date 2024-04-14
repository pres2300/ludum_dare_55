extends CharacterBody2D

@export var move_speed = 500

@onready var camera = $Camera2D

@onready var weapon_path = $WeaponPath
@onready var weapon_start_location = $WeaponLocation.position
var weapon = null

# Mouse input overrides other input
var mouse_held : bool = false
var mouse_position : Vector2 = Vector2.ZERO

var health = 100

# Objective counters
var current_summoning_items : int = 0

enum STATE { ALIVE, DEAD }
var player_state = STATE.ALIVE

func set_camera_limit(top, bottom, left, right):
	print("Top: ", top)
	print("bottom: ", bottom)
	print("left: ", left)
	print("right :", right)
	camera.limit_top = top
	camera.limit_bottom = bottom
	camera.limit_left = left
	camera.limit_right = right

func die():
	queue_free()

func take_damage(damage):
	if player_state == STATE.DEAD:
		return

	health -= damage
	if health <= 0:
		player_state = STATE.DEAD
		die()

func pickup_summoning_item():
	current_summoning_items += 1
	$PickupSound.play()

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

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_held = true
		else:
			mouse_held = false

func get_input():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _physics_process(_delta):
	var input_direction = get_input()
	velocity = input_direction*move_speed
	move_and_slide()

func _process(_delta):
	var attack_direction : Vector2 = Vector2.ZERO

	if mouse_held:
		attack_direction = global_position.direction_to(get_global_mouse_position())
	else:
		attack_direction = get_weapon_input()

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
