extends CharacterBody2D

@export var move_speed = 300

var health : int = 100
var can_move : bool = false
var target = null : set = set_target

func set_target(value):
	target = value

func die():
	queue_free()

func take_damage(damage):
	health -= damage
	if health <= 0:
		die()

func _physics_process(_delta):
	if can_move and target:
		velocity = global_position.direction_to(target.get_global_position())*move_speed
		move_and_slide()

func _on_visible_on_screen_notifier_2d_screen_entered():
	can_move = true

func _on_visible_on_screen_notifier_2d_screen_exited():
	can_move = false
