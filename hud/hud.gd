extends Node

@onready var paused = $MarginContainer/Paused
@onready var level_number = $MarginContainer/MarginContainer/HBoxContainer/LevelNumber
@onready var summon_items_collected = $MarginContainer/MarginContainer2/HBoxContainer2/SummonItemsCollected
@onready var health_bar = $MarginContainer2/PlayerHealth

var bar_textures = {
	"green": preload("res://assets/progress_bar/ProgressBar_Green.png"),
	"lime": preload("res://assets/progress_bar/ProgressBar_Lime.png"),
	"yellow": preload("res://assets/progress_bar/ProgressBar_Yellow.png"),
	"orange": preload("res://assets/progress_bar/ProgressBar_Orange.png"),
	"red": preload("res://assets/progress_bar/ProgressBar_Red.png"),
}

func show():
	$MarginContainer.show()
	$MarginContainer2.show()

func hide():
	$MarginContainer.hide()
	$MarginContainer2.hide()

func set_level_number(value : int):
	level_number.text = str(value)

func increment_summon_items_collected():
	var new_value = int(summon_items_collected.text) + 1
	summon_items_collected.text = str(new_value)

func reset_summon_items_collected():
	summon_items_collected.text = str(0)

func set_player_health(value : float):
	if health_bar == null:
		return

	if value/100.0 > 0.80:
		health_bar.texture_progress = bar_textures["green"]
	elif value/100.0 > 0.60:
		health_bar.texture_progress = bar_textures["lime"]
	elif value/100.0 > 0.40:
		health_bar.texture_progress = bar_textures["yellow"]
	elif value/100.0 > 0.20:
		health_bar.texture_progress = bar_textures["orange"]
	else:
		health_bar.texture_progress = bar_textures["red"]

	health_bar.value = value

func _input(event):
	if event.is_action_pressed("pause"):
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			paused.show()
		else:
			paused.hide()
