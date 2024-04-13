extends Area2D

@onready var sprite = $Sprite2D

@export var selected_texture = "res://assets/sprites/bone.png"
@export var unselected_texture = "res://assets/sprites/unbone.png"

var selected : bool = false

