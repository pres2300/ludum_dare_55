extends Control

@onready var start_button = $MarginContainer/VBoxContainer/MarginContainer/Button

signal start

func _ready():
	start_button.grab_focus()

func _on_button_pressed():
	start.emit()
