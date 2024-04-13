extends "res://weapons/range_weapons/range_weapon_base.gd"

func _ready():
	fire_rate = 10.0 # shots per second
	super()
	shoot_timer.timeout.connect(_shoot_timer_timeout)

func _shoot_timer_timeout():
	var b = projectile_scene.instantiate()
	get_tree().root.add_child(b)
	b.set_damage(base_damage)
	b.start($Muzzle.global_transform, flip_h, weilder)
	$ShootSound.play()
