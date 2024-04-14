extends AudioStreamPlayer2D

var damage_sounds = [
	preload("res://assets/sounds/damage_taken_1.mp3"),
	preload("res://assets/sounds/damage_taken_2.mp3"),
	preload("res://assets/sounds/damage_taken_3.mp3"),
	preload("res://assets/sounds/damage_taken_4.mp3"),
]

func play_random_sound():
	stream = damage_sounds[randi_range(0, damage_sounds.size()-1)]
	play()
