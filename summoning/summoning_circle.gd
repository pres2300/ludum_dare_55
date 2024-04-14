extends Node2D

@onready var boss_spawn_location = $BossSpawnLocation
@onready var portal_scene = load("res://next_level_portal.tscn")

var items_dropped : int = 0
var portal = null

signal spawn_boss

func add_portal():
	portal = portal_scene.instantiate()
	add_child(portal)
	portal.global_position = boss_spawn_location.global_position

func get_summoning_items():
	return $SummoningItemSlots.get_children()

func _summoning_item_dropped():
	items_dropped += 1

	if items_dropped == 5:
		spawn_boss.emit()

func _ready():
	for summon_item_slot in $SummoningItemSlots.get_children():
		summon_item_slot.selected.connect(_summoning_item_dropped)
