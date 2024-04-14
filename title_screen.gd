extends Control

@onready var start_button = $MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/StartButton

signal start

func _ready():
	start_button.grab_focus()

func _on_start_button_pressed():
	start.emit()

func _on_exit_button_pressed():
	get_tree().quit()
