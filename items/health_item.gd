extends Area2D

var heal_amount = 10

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.heal(heal_amount)
		call_deferred("queue_free")
