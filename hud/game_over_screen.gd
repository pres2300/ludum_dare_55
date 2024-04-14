extends Control

@onready var try_again_button = $Panel/MarginContainer2/HBoxContainer/TryAgainButton
@onready var main_menu_button = $Panel/MarginContainer2/HBoxContainer/MainMenuButton

signal try_again
signal main_menu

func _ready():
	try_again_button.grab_focus()

func _on_try_again_button_pressed():
	try_again.emit()
	queue_free()

func _on_main_menu_button_pressed():
	main_menu.emit()
	queue_free()
