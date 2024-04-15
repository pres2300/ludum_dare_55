extends "res://beings/enemy_pawn.gd"

@export var projectile_scene : PackedScene

# Stats
var attack_rate = 1.0 # per second
var base_damage = 5

var attack_timer = Timer.new()

signal boss_dead

func die():
	super()
	boss_dead.emit(global_position)

func _ready():
	super()
	is_boss = true
	can_move = true
	attack_timer.wait_time = 1.0/attack_rate
	attack_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
	$SpawnSound.play()
	add_child(attack_timer)
	attack_timer.timeout.connect(_attack_timer_timeout)
	attack_timer.start()

func _attack_timer_timeout():
	if not is_instance_valid(target):
		attack_timer.stop()
		return

	var b = projectile_scene.instantiate()
	get_tree().root.add_child(b)
	var dir = global_position.direction_to(target.global_position)
	$MouthLocation.rotation = dir.angle()
	b.set_damage(base_damage)
	b.start($MouthLocation.global_transform, false)
	$AttackSound.play()
