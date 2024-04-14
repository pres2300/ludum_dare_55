extends Area2D

signal next_level

func _on_body_entered(body):
	if body.is_in_group("Player"):
		next_level.emit()
