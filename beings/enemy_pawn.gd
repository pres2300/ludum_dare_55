extends CharacterBody2D

@export var health : float = 100.0 : set = set_health
@export var max_health : float = 100.0
@export var move_speed : int = 300

@onready var health_bar = $HealthBar


var can_move : bool = false
var target = null : set = set_target

var bar_textures = {
	"green": preload("res://assets/progress_bar/ProgressBar_Green.png"),
	"lime": preload("res://assets/progress_bar/ProgressBar_Lime.png"),
	"yellow": preload("res://assets/progress_bar/ProgressBar_Yellow.png"),
	"orange": preload("res://assets/progress_bar/ProgressBar_Orange.png"),
	"red": preload("res://assets/progress_bar/ProgressBar_Red.png"),
}

func set_health(value):
	health = value
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
	queue_free()

func take_damage(damage):
	health_bar.show()
	health -= damage
	if health <= 0:
		die()

func _ready():
	health_bar.max_value = max_health

func _physics_process(_delta):
	if can_move and target:
		velocity = global_position.direction_to(target.get_global_position())*move_speed
		move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_entered():
	can_move = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	health_bar.hide()
	can_move = false
