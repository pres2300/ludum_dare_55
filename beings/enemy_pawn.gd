extends CharacterBody2D

@export var health : float = 100.0 : set = set_health
@export var max_health : float = 100.0
@export var move_speed : int = 300

@onready var health_bar = $HealthBar
@onready var sprite = $Sprite2D
@onready var effect_popup_location = $EffectPopupLocation.position
@onready var effect_popup = load("res://hud/effect_popup.tscn")

var can_move : bool = false
var bounce_back : bool = false
var target = null : set = set_target
const bounce_distance : Vector2 = Vector2(200, 200)

enum STATE { ALIVE, DEAD }
var enemy_state = STATE.ALIVE

var bar_textures = {
	"green": preload("res://assets/progress_bar/ProgressBar_Green.png"),
	"lime": preload("res://assets/progress_bar/ProgressBar_Lime.png"),
	"yellow": preload("res://assets/progress_bar/ProgressBar_Yellow.png"),
	"orange": preload("res://assets/progress_bar/ProgressBar_Orange.png"),
	"red": preload("res://assets/progress_bar/ProgressBar_Red.png"),
}

func set_health(value):
	health = value

	if health_bar == null:
		return

	if value/max_health > 0.80:
		health_bar.texture_progress = bar_textures["green"]
	elif value/max_health > 0.60:
		health_bar.texture_progress = bar_textures["lime"]
	elif value/max_health > 0.40:
		health_bar.texture_progress = bar_textures["yellow"]
	elif value/max_health > 0.20:
		health_bar.texture_progress = bar_textures["orange"]
	else:
		health_bar.texture_progress = bar_textures["red"]

	health_bar.value = value

func set_target(value):
	target = value

func die():
	sprite.rotate(PI/2)
	$DieSound.play()
	$DieSound.finished.connect(queue_free)

func take_damage(damage):
	if enemy_state == STATE.DEAD:
		return

	health_bar.show()
	health -= damage

	if effect_popup:
		show_effect("Damage", damage)

	if health <= 0:
		enemy_state = STATE.DEAD
		die()

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

func _ready():
	health_bar.max_value = max_health

func _physics_process(_delta):
	if enemy_state == STATE.DEAD:
		return

	if can_move and is_instance_valid(target):
		if bounce_back:
			velocity = Vector2.ZERO
			global_position = global_position-(global_position.direction_to(target.get_global_position())*bounce_distance)
			bounce_back = false
		else:
			velocity = global_position.direction_to(target.get_global_position())*move_speed
		move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_entered():
	can_move = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	health_bar.hide()
	can_move = false

func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(5)
		bounce_back = true
