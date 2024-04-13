extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.pickup_summoning_item()
		queue_free()
