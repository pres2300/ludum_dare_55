extends Area2D

@onready var sprite = $Sprite2D

@export var selected_texture = preload("res://assets/sprites/bone.png")
@export var unselected_texture = preload("res://assets/sprites/unbone.png")

var is_activated : bool = false

signal selected

func _on_body_entered(body):
	if body.is_in_group("Player") and not is_activated:
		if body.drop_summoning_item() == true:
			sprite.texture = selected_texture
			is_activated = true
			$ActivateSound.play()
			selected.emit()

