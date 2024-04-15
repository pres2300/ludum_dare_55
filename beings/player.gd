extends CharacterBody2D

@export var move_speed = 500

@onready var camera = $Camera2D
@onready var effect_popup_location = $EffectPopupLocation.position
@onready var effect_popup = load("res://hud/effect_popup.tscn")
@onready var damage_sound = $DamageTakenSound
@onready var sprite = $Sprite2D

@onready var weapon_path = $WeaponPath
@onready var weapon_start_location = $WeaponLocation.position
var weapon = null

# Mouse input overrides other input
var mouse_held : bool = false
var mouse_position : Vector2 = Vector2.ZERO

var health = 100

# Objective counters
var current_summoning_items : int = 0

enum STATE { ALIVE, HURT, DEAD }
var player_state = STATE.ALIVE

signal summoning_item_collected
signal player_health_changed
signal player_died

func set_camera_limit(top, bottom, left, right):
	camera.limit_top = top
	camera.limit_bottom = bottom
	camera.limit_left = left
	camera.limit_right = right

func is_dead():
	if player_state == STATE.DEAD:
		return true
	else:
		return false

func disable_collision():
	$CollisionShape2D.disabled = true

func enable_collision():
	$CollisionShape2D.disabled = false

func die():
	player_state = STATE.DEAD
	if weapon:
		weapon.stop_attacking()
	sprite.rotate(PI/2)
	call_deferred("disable_collision")
	player_died.emit()

func heal(amount):
	if health + amount > 100:
		health = 100
	else:
		health += amount

	$HealSound.play()
	player_health_changed.emit(health)
	show_effect("Health", amount)

func can_take_damage():
	return player_state == STATE.ALIVE

func take_damage(damage):
	if is_dead():
		return

	disable_collision()
	player_state = STATE.HURT
	get_tree().create_timer(0.5).timeout.connect(_i_frames_done)
	damage_sound.play_random_sound()
	health -= damage
	player_health_changed.emit(health)

	if effect_popup:
		show_effect("Damage", damage)

	if health <= 0:
		player_state = STATE.DEAD
		die()

func pickup_summoning_item():
	current_summoning_items += 1
	$PickupSound.play()
	summoning_item_collected.emit()

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

func show_effect(type, value):
	var effect_popup_inst = effect_popup.instantiate()
	effect_popup_inst.position = effect_popup_location
	add_child(effect_popup_inst)

	var color = Color(0, 0, 0)
	var is_buff = false
	var is_crit = false
	match type:
		"Energy":
			color = Color(0.02221715450287, 0.25769451260567, 1)
			is_buff = true
		"Health":
			color = Color(0, 0.6627277135849, 0.00000154018403)
			is_buff = true
		"Damage":
			color = Color(0.859, 0.678, 0)
		_:
			color = Color(0, 0.6627277135849, 0.00000154018403)
			is_buff = true
	effect_popup_inst.show_value(value, is_crit, is_buff, color)

func get_input():
	return Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _i_frames_done():
	if is_dead():
		return

	player_state = STATE.ALIVE
	enable_collision()

func _unhandled_input(event):
	if is_dead():
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			mouse_held = true
		else:
			mouse_held = false

func _physics_process(_delta):
	if is_dead():
		return

	var input_direction = get_input()
	velocity = input_direction*move_speed
	move_and_slide()

func _process(_delta):
	if is_dead():
		return

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
