extends Area2D

@export var speed = 2000

var velocity = Vector2.ZERO
var damage = 5 : set = set_damage
var weilder = null

func start(_transform, flip_h, new_weilder):
	weilder = new_weilder
	# Only get the origin and rotation of the _transform to avoid scale issues
	position = _transform.get_origin()
	if flip_h:
		rotation = _transform.get_rotation()-PI
	else:
		rotation = _transform.get_rotation()
	velocity = (transform.x/transform.get_scale().x)*speed

func set_damage(value):
	damage = value

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(delta):
	position += velocity*delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	#if body.is_dead() or body == weilder:
		#return
#
	body.take_damage(damage)
	queue_free()
