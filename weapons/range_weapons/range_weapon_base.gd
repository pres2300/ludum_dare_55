extends Area2D

@export var projectile_scene : PackedScene

@onready var sprite = $Sprite2D
@onready var hold = $Hold
@onready var muzzle = $Muzzle

# Stats
var fire_rate = 1.0 # shots per second
var base_damage = 5

var shooting = false
var shoot_timer = Timer.new()
var flip_h = false : set = set_flip_h

func set_target_rotation(angle):
	if flip_h:
		rotation = angle-PI
	else:
		rotation = angle

func set_flip_h(flip):
	if flip_h != flip:
		sprite.flip_h = flip
		hold.position *= Vector2(-1, 1)
		muzzle.position *= Vector2(-1, 1)
		flip_h = flip

func get_hold_position():
	return hold.position*scale

func start_attacking():
	if not shooting:
		shooting = true
		shoot_timer.start()

func stop_attacking():
	if shooting:
		shooting = false
		shoot_timer.stop()

func _ready():
	shoot_timer.wait_time = 1.0/fire_rate
	shoot_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(shoot_timer)
