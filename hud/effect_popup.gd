extends Label

@onready var tween = get_tree().create_tween()

@export var travel = Vector2(0, -50)
@export var duration = 0.3
@export var spread = PI/4
@export var crit_color = Color(1.0, 0, 0)
@export var base_color = Color(0.859, 0.678, 0)

func show_value(value, crit=false, buff=false, color=base_color):
	text = "+"+str(value) if buff else str(value)

	var movement = travel.rotated(randf_range(-spread/2, spread/2))
	pivot_offset = size/2

	if crit:
		self.modulate = crit_color
		tween.parallel().tween_property(self, "scale", scale*1.5, duration)
	else:
		self.modulate = color
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.parallel().tween_property(self, "global_position", global_position + movement, duration)
	tween.tween_property(self, "modulate:a", 0, duration)

	tween.tween_callback(self.queue_free)
