extends Node

@onready var paused = $MarginContainer/Paused

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			paused.show()
		else:
			paused.hide()
